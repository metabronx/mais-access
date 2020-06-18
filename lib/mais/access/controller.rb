# frozen_string_literal: true

module MaisAccess
  module Controller
    require "mais/access/dispatcher"
    require "mais/access/user"

    include MaisAccess::Dispatcher

    MAIS_CLIENT = (Rails.application.credentials[:client] || "unregistered").freeze
    PROMPT = "access - MAIS - #{MAIS_CLIENT}"
    public_constant :MAIS_CLIENT
    private_constant :PROMPT

    def mais_user
      @mais_user ||= MaisAccess::User.new(session[:mais_user])
    end

    private

    def authenticate_mais_user!
      valid_jwt? || authenticate_or_request_with_http_basic(PROMPT) do |l, p|
        user?(l, p)
      end
    end
  end
end
