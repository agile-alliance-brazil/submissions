# encoding: UTF-8
require File.join(File.dirname(__FILE__), '00_app_config') unless defined?(AppConfig)

if AppConfig[:airbrake]
  Airbrake.configure do |config|
    config.ignore_environments = %w(development test)
    config.project_id = AppConfig[:airbrake][:project_id]
    config.project_key = AppConfig[:airbrake][:project_key]
    config.environment = AppConfig[:airbrake][:environment] || 'development'
  end
end
