config = YAML.load_file("#{RAILS_ROOT}/config/config.yml")

::AppConfig = config
ActionMailer::Base.smtp_settings = config[:smtp_settings]
ActionMailer::Base.default_url_options[:host] = config[:host]
