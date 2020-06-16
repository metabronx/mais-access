# frozen_string_literal: true

module MaisAccess
  class Railtie < ::Rails::Railtie
    initializer("mais.middleware") do |_app|
      # Hook into ActionController's loading process
      ActiveSupport.on_load(:action_controller) do
        require "mais/access/dispatcher"
        include MaisAccess::Dispatcher

        MAIS_CLIENT = (Rails.application.credentials[:client] || "unregistered").freeze

        public_constant :MAIS_CLIENT

        # Mark the `mais_user` reader method (defined in Mais::Dispatcher) as a
        # helper so that it can be accessed from a view
        helper_method :mais_user

        # Force a MAIS user authentication check on every request
        before_action :authenticate_mais_user!

        # "Cross-Site Request Forgery (CSRF) is an attack that allows a malicious user
        # to spoof legitimate requests to your server, masquerading as an authenticated
        # user. Rails protects against this kind of attack by generating unique tokens
        # and validating their authenticity with each submission."
        #
        # https://link.medium.com/q1U60lAYm7
        #
        # If Rails detects an invalid authentication token, we reset the current session.
        protect_from_forgery with: :reset_session, prepend: true
      end
    end
  end
end
