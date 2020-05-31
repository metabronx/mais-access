# frozen_string_literal: true

module MaisAccess
	class Railtie < ::Rails::Railtie
		initializer('mais.middleware') do |app|
			# Hook into ActionController's loading process
			ActiveSupport.on_load(:action_controller) do
				require 'mais-access/dispatcher'
				include MaisAccess::Dispatcher

				# Mark the `mais_user` reader method (defined in Mais::Dispatcher) as a
				# helper so that it can be accessed from a view
				helper_method :mais_user

				# Force a MAIS user authentication check on every request
				before_action :authenticate_mais_user!
			end
		end
	end
end