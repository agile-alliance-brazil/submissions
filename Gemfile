# encoding: utf-8
source 'https://rubygems.org'
ruby '2.4.3'

def linux_only(require_as)
  RbConfig::CONFIG['host_os'] =~ /linux/ ? require_as : false
end
# Mac OS X
def darwin_only(require_as)
  RbConfig::CONFIG['host_os'] =~ /darwin/ ? require_as : false
end

gem 'acts-as-taggable-on', '~> 5.0', '>= 5.0.0'
gem 'acts_as_commentable', '4.0.2'
gem 'airbrake', '~> 7.0'
gem 'aws-ses', '0.6.0', require: 'aws/ses'
gem 'brhelper', '3.3.0'
gem 'cancancan', '~> 2.0'
gem 'coffee-rails', '~> 4.2', '>= 4.2.2'
gem 'devise', '~> 4.7', '>= 4.7.1'
gem 'devise-encryptable', '0.2.0'
gem 'devise-i18n', '~> 1.9', '>= 1.9.1'
gem 'doorkeeper', '~> 4.4', '>= 4.4.3' # TODO: Remove in favor of oauth in another app
gem 'fancybox-rails', '~> 0.3', '>= 0.3.1'
gem 'formtastic', '3.1.5'
gem 'goalie', git: 'https://github.com/hugocorbucci/goalie.git'
gem 'haml', '~> 5.0'
gem 'jquery-rails', '~> 4.4', '>= 4.4.0'
gem 'jquery-ui-rails', '~> 6.0', '>= 6.0.1'
gem 'localized_country_select', '0.9.11'
gem 'modernizr-rails'
gem 'mysql2', '< 0.5' # remove restriction once rails supports mysql 0.5+
gem 'newrelic_rpm'
gem 'paperclip', '~> 6.1', '>= 6.1.0'
gem 'rails', '~> 4.2', '>= 4.2.11.3' # TODO: Upgrade
gem 'sass-rails', '~> 5.0', '>= 5.0.7'
gem 'seed-fu', '~> 2.3', '>= 2.3.9'
gem 'state_machine', '1.2.0'
gem 'therubyracer', '0.12.3'
gem 'uglifier', '~> 4.0'
gem 'validates_existence', '0.9.2'
gem 'will_paginate', '~> 3.1'
gem 'yui-compressor', '~> 0.12'

platforms :ruby do
  gem 'RedCloth', '~> 4.3', require: 'redcloth'
end

group :development do
  gem 'bullet', '>= 5.9.0'
  gem 'capistrano', '3.10.1', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-git-with-submodules', require: false
  gem 'capistrano-rails', require: false
  gem 'capistrano-rvm', require: false
  gem 'dotenv-rails', '>= 2.7.5', require: false
  gem 'foreman'
  gem 'lol_dba', '>= 2.2.0'
  gem 'rack-livereload', '>= 0.3.17'
  gem 'travis-lint', '>= 2.0.0'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'codeclimate-test-reporter', '~> 1.0.9'
  gem 'email_spec'
  gem 'mocha'
  gem 'simplecov', '>= 0.13.0'
  gem 'shoulda-matchers', '>= 4.0.1'
end

group :development, :test do
  gem 'brakeman'
  gem 'factory_bot_rails', '~> 4.11', '>= 4.11.1' # 5 doesn't support rails 4.2
  gem 'faker'
  gem 'guard-livereload'
  gem 'guard-rspec'
  gem 'poltergeist', '>= 1.18.1', require: 'capybara/poltergeist'
  gem 'byebug'
  gem 'pry-rails'
  gem 'rb-readline'
  gem 'rb-fsevent', require: darwin_only('rb-fsevent')
  gem 'rb-inotify', require: linux_only('rb-inotify')
  gem 'rspec-rails', '>= 3.9.1', '< 4.0'
  gem 'rspec-its'
  gem 'rspec-collection_matchers'
  gem 'selenium-webdriver'
  gem 'spring', '>= 2.0.2'
  gem 'spring-commands-rspec', '>= 1.0.4'
  gem 'sqlite3', '~> 1.3.13'
  gem 'terminal-notifier-guard', require: darwin_only('terminal-notifier-guard')
  gem 'timecop'
  gem 'rubocop', require: false
  gem 'rubocop-rspec'
end
