source 'http://rubygems.org'

gem 'rails', '=3.2.12'
gem 'jquery-rails', '=2.1.0'
gem 'haml', '=3.1.4'
gem 'will_paginate', '=3.0.3'
gem 'formtastic', '=2.2.1'
gem 'inherited_resources', '=1.3.1'
gem 'has_scope', '=0.5.1'
gem 'devise', '=2.2.3'
gem 'devise-encryptable', '=0.1.1'
gem 'magic-localized_country_select', '=0.2.0', :require => 'localized_country_select'
gem 'brhelper', '=3.1.0'
gem 'brcpfcnpj', '=3.1.0'
gem 'seed-fu', '=2.2.0'
gem 'acts-as-taggable-on', '=2.3.3'
gem 'cancan', '=1.6.8'
gem 'acts_as_commentable', '=3.0.1'
gem 'state_machine', '=1.1.2'
gem 'validates_existence', '=0.7.1'
gem 'goalie', '=0.0.4'
gem 'airbrake', '=3.1.2'
gem 'aws-ses', '=0.4.4', :require => 'aws/ses'
gem 'mysql2', '=0.3.11'

platforms :ruby do
  gem 'RedCloth', '=4.2.9', :require => 'redcloth'
end
platforms :mswin, :mingw do
  gem 'RedCloth', '=4.2.9', :require => 'redcloth', :platforms => :mswin
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'therubyracer', '=0.11.3'
  gem 'sass-rails', '=3.2.5'
  gem 'yui-compressor', '=0.9.6'
  gem 'johnson', '=1.2.0'
  gem 'jquery-ui-rails', '=1.1.1'
  gem 'coffee-rails', '=3.2.2'
  gem 'fancybox-rails', '=0.1.4'
end

group :development do
  gem 'capistrano-ext', '=1.2.1'
  gem 'travis-lint', '=1.6.0'
  gem 'foreman', '=0.61.0'
end

group :development, :test do
  gem 'mocha', '=0.13.2', :require => false
  gem 'sqlite3', '=1.3.7'
  gem 'rspec-rails', '=2.12.2'
  gem 'shoulda-matchers', '=1.2.0'
  gem 'factory_girl_rails', '=1.7.0'
  gem 'rcov', '=1.0.0'
  gem 'spork-rails', '=3.2.1'
  gem 'jasminerice', '=0.0.9'
  gem 'guard-jasmine', '=1.7.0'
  gem 'jasmine-jquery-rails', '=1.3.1'
end