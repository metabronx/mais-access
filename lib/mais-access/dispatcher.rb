module MaisAccess
    module Dispatcher
        require 'net/http'
        require 'uri'
        require 'json'
        require 'mais-access/user'

        attr_reader :mais_user

        def authenticate_mais_user!
            # Prompt the user for HTTP Basic credentials, or authenticate if they are cached in the session
            authenticate_or_request_with_http_basic("mais ~ access") do |login, password|
                begin
                    # Get the credentials and POST them to `accounts.scenycwork.net/authenticate`
                    response = Net::HTTP.post_form(URI("http://localhost:3000/authenticate"), { "username" => login, "password" => password })
                    # Parse the JSON response
                    body = JSON.parse(response.body)

                    # If the user is valid, set the current mais user and passes the filter action
                    if response.code == '200' && body["authenticated"]
                        @mais_user = MaisAccess::User.new(body["user"])
                        return true
                    end
                rescue => e
                    # Something went wrong, so save our butts and don't them in.
                    Rails.logger.error(e)
                end
            end
        end
    end
end