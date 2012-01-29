if ENV['RAILS_ENV'] == 'production'
  ENV['GEM_PATH'] = File.expand_path("~/.gems") + ":/usr/lib/ruby/gems/1.8"
end

# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
AgileBrazil::Application.initialize!
