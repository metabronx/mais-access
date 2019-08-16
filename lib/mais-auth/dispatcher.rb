module MaisAuth
    module Dispatcher
        require 'net/http'
        require 'uri'
        require 'json'

        def authenticate_mais_user!
            authenticate_or_request_with_http_basic("mais ~ authorization") do |login, password|
                response = Net::HTTP.post_form(URI("http://localhost:3000/authenticate"), { "username" => login, "password" => password })
                body = JSON.parse(response.body)
                body["authenticated"]
            end
        end
    end
end