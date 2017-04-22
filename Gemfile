# encoding: utf-8
source 'https://rubygems.org'
ruby '2.3.3'

def linux_only(require_as)
  RbConfig::CONFIG['host_os'] =~ /linux/ ? require_as : false
end
# Mac OS X
def darwin_only(require_as)
  RbConfig::CONFIG['host_os'] =~ /darwin/ ? require_as : false
end

gem 'acts-as-taggable-on', '~> 4.0'
gem 'acts_as_commentable', '4.0.2'
gem 'airbrake', '~> 6.0'
gem 'aws-ses', '0.6.0', require: 'aws/ses'
gem 'brhelper', '3.3.0'
gem 'cancancan', '~> 1.10'
gem 'coffee-rails', '~> 4.1'
gem 'devise', '~> 4.0'
gem 'devise-encryptable', '0.2.0'
gem 'devise-i18n', '~> 1.0'
gem 'doorkeeper', '~> 3.1' # TODO: Remove
gem 'fancybox-rails', '~> 0.3'
gem 'formtastic', '3.1.5'
gem 'goalie', git: 'https://github.com/hugocorbucci/goalie.git'
gem 'haml', '~> 4.0'
gem 'jquery-rails', '~> 4.0'
gem 'jquery-ui-rails', '~> 6.0'
gem 'localized_country_select', '0.9.11'
gem 'modernizr-rails'
gem 'mysql2', '~> 0.4'
gem 'newrelic_rpm'
gem 'paperclip', '~> 5.0'
gem 'rails', '~> 4.2' # TODO: 5.0 needs konacha > 4.0.0
gem 'sass-rails', '~> 5.0'
gem 'seed-fu', '~> 2.3'
gem 'state_machine', '1.2.0'
gem 'therubyracer', '0.12.3'
gem 'uglifier', '~> 3.0'
gem 'validates_existence', '0.9.2'
gem 'will_paginate', '~> 3.1'
gem 'yui-compressor', '~> 0.12'

platforms :ruby do
  gem 'RedCloth', '~> 4.3', require: 'redcloth'
end

group :development do
  gem 'bullet'
  gem 'byebug'
  gem 'capistrano', '3.8.1', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-git-with-submodules', require: false
  gem 'capistrano-rails', require: false
  gem 'capistrano-rvm', require: false
  gem 'dotenv-rails', require: false
  gem 'foreman'
  gem 'lol_dba'
  gem 'rack-livereload'
  gem 'travis-lint'
  gem 'web-console'
end

group :test do
  gem 'codeclimate-test-reporter', '~> 1.0.0'
  gem 'email_spec'
  gem 'mocha'
  gem 'simplecov'
  gem 'shoulda-matchers'
end

group :development, :test do
  gem 'brakeman'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'guard-konacha-rails'
  gem 'guard-livereload'
  gem 'guard-rspec'
  gem 'konacha' # TODO: Rails 5.0 needs konacha > 4.0.0
  gem 'poltergeist', require: 'capybara/poltergeist'
  gem 'pry-rails'
  gem 'rb-fsevent', require: darwin_only('rb-fsevent')
  gem 'rb-inotify', require: linux_only('rb-inotify')
  gem 'rspec-rails'
  gem 'rspec-its'
  gem 'rspec-collection_matchers'
  gem 'selenium-webdriver'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'sqlite3'
  gem 'terminal-notifier-guard', require: darwin_only('terminal-notifier-guard')
  gem 'timecop'
  gem 'rubocop', require: false
end
