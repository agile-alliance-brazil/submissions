# frozen_string_literal: true

ActionMailer::Base.smtp_settings = APP_CONFIG[:smtp_settings]
ActionMailer::Base.default_url_options[:host] = APP_CONFIG[:host]
