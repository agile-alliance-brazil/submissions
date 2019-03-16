# frozen_string_literal: true

config_file = File.join(File.dirname(__FILE__), '..', '..', 'config', 'config.yml')
raise 'config/config.yml file not found. Please check config/config.example for a sample' unless File.exist?(config_file)

config = HashWithIndifferentAccess.new(YAML.load_file(config_file))

::APP_CONFIG = config
