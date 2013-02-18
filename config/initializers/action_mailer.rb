ActionMailer::Base.smtp_settings = AppConfig[:smtp_settings]
ActionMailer::Base.default_url_options[:host] = AppConfig[:host]
