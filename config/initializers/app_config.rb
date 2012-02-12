# encoding: UTF-8
begin
  config = YAML.load_file("#{Rails.root}/config/config.yml")

  ::AppConfig = config
  ActionMailer::Base.smtp_settings = config[:smtp_settings]
  ActionMailer::Base.default_url_options[:host] = config[:host]
rescue
  raise "config/config.yml file not found. Please check config/config.example for a sample"
end
