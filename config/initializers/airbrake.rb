# encoding: UTF-8
if AppConfig[:airbrake]
  Airbrake.configure do |config|
    config.api_key = AppConfig[:airbrake][:access_key]
  end
end
