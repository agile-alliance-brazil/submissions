# frozen_string_literal: true

require File.join(File.dirname(__FILE__), '00_app_config') unless defined?(APP_CONFIG)

if APP_CONFIG[:airbrake]
  Airbrake.configure do |config|
    config.ignore_environments = %w[development test]
    config.project_id = APP_CONFIG[:airbrake][:project_id]
    config.project_key = APP_CONFIG[:airbrake][:project_key]
    config.environment = APP_CONFIG[:airbrake][:environment] || 'development'
  end
end
