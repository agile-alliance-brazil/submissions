# frozen_string_literal: true

Recaptcha.configure do |config|
  config.site_key = APP_CONFIG[:recaptcha][:site_key]
  config.secret_key = APP_CONFIG[:recaptcha][:secret_key]

  # Uncomment the following line if you are using a proxy server:
  # config.proxy = 'http://myproxy.com.au:8080'

  # Uncomment the following lines if you are using the Enterprise API:
  # config.enterprise = true
  # config.enterprise_api_key = 'AIzvFyE3TU-g4K_Kozr9F1smEzZSGBVOfLKyupA'
  # config.enterprise_project_id = 'my-project'
end
