# frozen_string_literal: true

module MaisAccess
  module Dispatcher
    require "net/https"
    require "uri"
    require "json"
    require "mais/access/user"

    MAIS_CLIENT = (Rails.application.credentials[:client] || "unregistered").freeze
    PROMPT = "access - MAIS - #{MAIS_CLIENT}"
    API_HOSTNAME = ENV["MAIS_ACCOUNTS_HOSTNAME"]
    AUTH_ENDPOINT = "#{API_HOSTNAME}/api/authenticate"
    JWT_ENDPOINT = "#{API_HOSTNAME}/api/verify"

    public_constant :MAIS_CLIENT
    private_constant :PROMPT
    private_constant :API_HOSTNAME
    private_constant :AUTH_ENDPOINT
    private_constant :JWT_ENDPOINT

    def authenticate_mais_user!
      valid_jwt? || authenticate_or_request_with_http_basic(PROMPT) { |l, p| user?(l, p) }
    end

    def mais_user
      session[:mais_user]
    end

    private

    def make_http(endpoint)
      uri = URI(endpoint)

      # Setup https connection and specify certificate bundle if in production
      if Rails.env.production?
        http = Net::HTTP.new(uri.host, 443)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        http.cert_store = OpenSSL::X509::Store.new
        http.cert_store.set_default_paths
        http.cert_store.add_file("/etc/pki/tls/certs/server.crt")
      else
        # otherwise, just use what was given to us
        http = Net::HTTP.new(uri.host, uri.port)
      end

      return uri.path, http
    end

    def set_session(mais_user = nil, jwt = nil)
      reset_session
      session[:mais_user] = mais_user
      session[:jwt] = jwt
    end

    def valid_jwt?
      return false if session[:jwt].blank?

      uri, http = make_http(JWT_ENDPOINT)

      # Try to access the verification page with the stored JWT
      request = Net::HTTP::Get.new(uri)
      request["Authorization"] = session[:jwt]
      response = http.request(request)

      # If the server returns HTTP 204 No Content, the token is valid
      return true if response.code == "204"

      # invalid token, force a session reset
      set_session
      false
    end

    def user?(login, password)
      begin
        uri, http = make_http(AUTH_ENDPOINT)

        # Post the credentials to the authentication endpoint
        request = Net::HTTP::Post.new(uri, { "Content-Type" => "application/json" })
        request.body = JSON.generate({ user: { username: login, password: password } })
        response = http.request(request)

        # Parse the response body as JSON
        body = response.read_body

        # If the user is valid, reset the session and set the current mais user
        if response.code == "201" && body["user"]
          set_session(MaisAccess::User.new(body["user"]), response["Authorization"])
          return true
        end
      rescue StandardError => e
        Rails.logger.error(e)
      end

      # Something went wrong, so save our butts and don't them in
      false
    end
  end
end
