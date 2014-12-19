#encoding: UTF-8
Konacha.configure do |config|
  require 'capybara/poltergeist'
  config.driver = :poltergeist
end if defined?(Konacha)
