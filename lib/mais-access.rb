module MaisAccess
	class Railtie < ::Rails::Railtie
		initializer('mais.middleware') do |app|
			# Hook into ActionController's loading process
			ActiveSupport.on_load(:action_controller) do
				require 'mais-access/dispatcher'
				include MaisAccess::Dispatcher

				# Force a MAIS user authentication check on every request
				before_action :authenticate_mais_user!
			end
		end
	end
end