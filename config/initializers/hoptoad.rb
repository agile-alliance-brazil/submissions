# encoding: UTF-8
if AppConfig[:hoptoad]
  HoptoadNotifier.configure do |config|
    config.api_key = AppConfig[:hoptoad][:access_key]
  end
end
