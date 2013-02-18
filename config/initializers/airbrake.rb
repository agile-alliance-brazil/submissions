# encoding: UTF-8
require File.join(File.dirname(__FILE__), '00_app_config') unless defined?(AppConfig)

if AppConfig[:airbrake]
  Airbrake.configure do |config|
    config.api_key = AppConfig[:airbrake][:access_key]
  end
end
