module MaisAccess
    module Dispatcher
        require 'net/https'
        require 'uri'
        require 'json'
        require 'mais-access/user'

        attr_reader :mais_user

        MAIS_CLIENT = ENV['MAIS_CLIENT']

        def authenticate_mais_user!
            # Prompt the user for HTTP Basic credentials, or authenticate if they are cached in the session
            authenticate_or_request_with_http_basic("access - MAIS - #{MAIS_CLIENT}") do |login, password|
                begin
                    # Setup https connection and specify certificate bundle
                    url = URI("#{ENV['MAIS_ACCOUNTS_HOSTNAME']}/authenticate")
                    http = Net::HTTP.new(url.host, 443)
                    http.use_ssl = true
                    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
                    http.cert_store = OpenSSL::X509::Store.new
                    http.cert_store.set_default_paths
                    http.cert_store.add_file("/etc/pki/tls/certs/server.crt")

                    # Get the credentials and POST them to `accounts.scenycwork.net/authenticate`
                    request = Net::HTTP::Post.new(url.path, {'Content-Type' => 'application/json'})
                    request.set_form_data({ "username" => login, "password" => password })
                    response = http.request(request)

                    # If the user is valid, set the current mais user and passes the filter action
                    if response.code == '200' && body["authenticated"]
                        @mais_user = MaisAccess::User.new(body["user"])
                        return true
                    end
                rescue => e
                    # Something went wrong, so save our butts and don't them in.
                end
            end
        end
    end
end