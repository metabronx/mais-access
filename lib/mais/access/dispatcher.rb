# frozen_string_literal: true

module MaisAccess
  module Dispatcher
    AUTH_ENDPOINT = "#{ENV.fetch("MAIS_ACCOUNTS_HOSTNAME")}/api/authenticate"
    JWT_ENDPOINT = "#{ENV.fetch("MAIS_ACCOUNTS_HOSTNAME")}/api/verify"
    private_constant :AUTH_ENDPOINT
    private_constant :JWT_ENDPOINT

    private

    def set_session(user = nil, jwt = nil)
      reset_session
      session[:mais_user] = user
      session[:jwt] = jwt
    end

    def make_secure_http(endpoint)
      uri = URI(endpoint)

      begin
        # Setup and yield an HTTPS connection to the specified endpoint
        Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
          yield(uri.path, http)
        end
      rescue StandardError => e
        Rails.logger.error(e)
        # Something went wrong, so save our butts and don't them in
        false
      end
    end

    def valid_jwt?
      return false if session[:mais_user].blank? || session[:jwt].blank?

      make_secure_http(JWT_ENDPOINT) do |path, http|
        # Try to access the verification endpoint with the stored JWT
        request = Net::HTTP::Get.new(path)
        request["Authorization"] = session[:jwt]
        response = http.request(request)

        # If the server returns HTTP 204 No Content, the token is valid.
        # `next` is required instead of `return` because `return` exits
        # without finishing the block execution (cleaning up)
        next true if response.code == "204"

        # invalid token, force a session reset
        set_session
        false
      end
    end

    def user?(login, password)
      make_secure_http(AUTH_ENDPOINT) do |path, http|
        # Post the credentials to the authentication endpoint
        request = Net::HTTP::Post.new(path, { "Content-Type" => "application/json" })
        request.body = JSON.generate({ user: { username: login, password: password } })
        response = http.request(request)

        # Parse the response body as JSON
        body = JSON.parse(response.body)

        # If the user is valid, reset the session and set the current mais user
        if response.code == "201" && body["user"]
          set_session(body["user"], response["Authorization"])
          next true
        end

        false
      end
    end
  end
end
