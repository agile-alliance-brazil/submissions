# encoding: UTF-8

config_file = File.join(File.dirname(__FILE__), '..', '..', 'config', 'config.yml')
unless File.exist?(config_file)
  raise "config/config.yml file not found. Please check config/config.example for a sample"
end
config = HashWithIndifferentAccess.new(YAML.load_file(config_file))

::AppConfig = config
