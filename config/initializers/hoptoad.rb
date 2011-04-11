if App::Config[:hoptoad]
  HoptoadNotifier.configure do |config|
    config.api_key = App::Config[:hoptoad][:access_key]
  end
end