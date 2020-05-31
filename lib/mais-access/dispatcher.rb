# frozen_string_literal: true

module MaisAccess
  module Dispatcher
    require 'net/https'
    require 'uri'
    require 'json'
    require 'mais-access/user'

    attr_reader :mais_user

    MAIS_CLIENT = ENV['MAIS_CLIENT']
    APP_TITLE = "access - MAIS - #{MAIS_CLIENT}"

    def authenticate_mais_user!
      # Prompt the user for HTTP Basic credentials or authenticate if they are
      # cached in the browser session
      authenticate_or_request_with_http_basic(APP_TITLE) { |l, p| user?(l, p) }
    end

    private

    def user?(login, password)
      begin
        url = URI("#{ENV['MAIS_ACCOUNTS_HOSTNAME']}/authenticate")

        # Setup https connection and specify certificate bundle if enabled
        if (ENV.fetch("USE_HTTPS") { false })
          http = Net::HTTP.new(url.host, 443)
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_PEER
          http.cert_store = OpenSSL::X509::Store.new
          http.cert_store.set_default_paths
          http.cert_store.add_file("/etc/pki/tls/certs/server.crt")
        else
          http = Net::HTTP.new(url.host, url.port)
        end

        # Get the credentials and POST them to `accounts.scenycwork.net/authenticate`
        request = Net::HTTP::Post.new(url.path, {'Content-Type' => 'application/json'})
        request.set_form_data({ "username" => login, "password" => password })
        response = http.request(request)

        # Parse the response body as JSON
        body = JSON.parse(response.body)

        # If the user is valid, set the current mais user
        if response.code == '200' && body["authenticated"]
          @mais_user = MaisAccess::User.new(body["user"])
          # let them in
          return true
        end
      rescue => e
        Rails.logger.error(e)
      end

      # Something went wrong, so save our butts and don't them in.
      return false
    end
  end
end