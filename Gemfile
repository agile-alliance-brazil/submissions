#encoding: utf-8 
source 'http://rubygems.org'

gem 'rails', '=3.2.16'
gem 'jquery-rails', '=3.0.4'
gem 'haml', '=4.0.3'
gem 'will_paginate', '=3.0.4'
gem 'formtastic', '=2.2.1'
gem 'inherited_resources', '=1.3.1'
gem 'has_scope', '=0.5.1'
gem 'devise', '=3.0.1'
gem 'devise-encryptable', '=0.1.2'
gem 'magic-localized_country_select', '=0.2.0', :require => 'localized_country_select'
gem 'brhelper', '=3.3.0'
gem 'seed-fu', '=2.2.0'
gem 'acts-as-taggable-on', '=2.4.1'
gem 'cancan', '=1.6.10'
gem 'acts_as_commentable', '=3.0.1' # version 4.0.0 require ruby 1.9
gem 'state_machine', '=1.2.0'
gem 'validates_existence', '=0.8.0'
gem 'goalie', '=0.0.4'
gem 'airbrake', '=3.1.12'
gem 'aws-ses', '=0.5.0', :require => 'aws/ses'
gem 'mysql2', '=0.3.13'
gem 'doorkeeper', '=0.6.7'

platforms :ruby do
  gem 'RedCloth', '=4.2.9', :require => 'redcloth'
end
platforms :mswin, :mingw do
  gem 'RedCloth', '=4.2.9', :require => 'redcloth', :platforms => :mswin
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'therubyracer', '=0.12.0'
  gem 'sass-rails', '=3.2.6'
  gem 'yui-compressor', '=0.11.0'
  gem 'jquery-ui-rails', '=4.0.4'
  gem 'coffee-rails', '=3.2.2' # 4.0.0 for rails 4
  gem 'fancybox-rails', '=0.2.1'
end

group :development do
  gem 'capistrano-ext', '=1.2.1'
  gem 'travis-lint', '=1.7.0'
  gem 'foreman', '=0.63.0'
  gem 'bullet', '=4.6.0'
  gem 'lol_dba', '=1.6.0'
end

group :test do
  gem 'mocha', '=0.14.0'
  gem 'shoulda-matchers', '=2.0.0' # version 2.2+ requires ruby 1.9+
  gem 'factory_girl_rails', '=1.7.0' # version 2+ requires factory_girl 3+, which dropped support for ruby 1.8
  gem 'simplecov', '=0.8.2'
  gem 'email_spec', '=1.5.0'
end

group :development, :test do
  gem 'sqlite3', '=1.3.7'
  gem 'rspec-rails', '=2.14.0'
  gem 'spork-rails', '=3.2.1'
  gem 'jasmine-jquery-rails', '=1.5.6'
  gem 'guard-jasmine', '=1.14.0' # 1.15.0 dropped support for ruby 1.8
  gem 'jasminerice', '=0.0.10'
  gem 'coveralls', '=0.6.7', :require => false
end