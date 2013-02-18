# encoding: UTF-8

config_file = File.join(File.dirname(__FILE__), '..', '..', 'config', 'config.yml')
unless File.exist?(config_file)
  raise "config/config.yml file not found. Please check config/config.example for a sample"
end
config = YAML.load_file(config_file)

::AppConfig = config
ActionMailer::Base.smtp_settings = config[:smtp_settings]
ActionMailer::Base.default_url_options[:host] = config[:host]

module ActionView
  module Helpers
    module FormOptionsHelper
      SUPPORTED_LANGUAGES = [['Português', 'pt'], ['English', 'en']]
    end
  end
end
