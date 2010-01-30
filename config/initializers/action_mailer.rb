mailer_config = YAML.load_file("#{RAILS_ROOT}/config/mailer.yml")

ActionMailer::Base.smtp_settings = mailer_config[:smtp_settings]
ActionMailer::Base.default_url_options[:host] = mailer_config[:host]