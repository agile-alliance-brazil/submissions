# frozen_string_literal: true

Recaptcha.configure do |config|
  config.site_key = '6LdrRIwgAAAAAAgiuPNYvSL-kEtTyeQa8N2mekqV'
  config.secret_key = '6LdrRIwgAAAAABUa63LGx4kgGmgBuPe8O7McSCmb'

  # Uncomment the following line if you are using a proxy server:
  # config.proxy = 'http://myproxy.com.au:8080'

  # Uncomment the following lines if you are using the Enterprise API:
  # config.enterprise = true
  # config.enterprise_api_key = 'AIzvFyE3TU-g4K_Kozr9F1smEzZSGBVOfLKyupA'
  # config.enterprise_project_id = 'my-project'
end
