#encoding: utf-8 
source 'http://rubygems.org'
ruby '1.9.3'

def linux_only(require_as)
  RbConfig::CONFIG['host_os'] =~ /linux/ ? require_as : false
end
# Mac OS X
def darwin_only(require_as)
  RbConfig::CONFIG['host_os'] =~ /darwin/ ? require_as : false
end

gem 'rails', '3.2.21' # Issue #114 - 4.0.2 is target
gem 'activemodel', '3.2.21', require: 'active_model' # Remove once issue #114 is done as this is part of rails 4
gem 'strong_parameters', '0.2.3' # Remove once issue #114 is done as this is part of rails 4
gem 'jquery-rails', '3.1.2'
gem 'haml', '4.0.6'
gem 'will_paginate', '3.0.7'
gem 'formtastic', '3.1.2'
gem 'inherited_resources', '1.5.1'
gem 'has_scope', '0.6.0.rc'
gem 'devise', '3.4.1'
gem 'devise-encryptable', '0.2.0'
gem 'magic-localized_country_select', '0.2.0', require: 'localized_country_select'
gem 'brhelper', '3.3.0'
gem 'seed-fu', '2.3.3'
gem 'acts-as-taggable-on', '3.4.2'
gem 'cancan', '1.6.10'
gem 'acts_as_commentable', '3.0.1' # version 4.0.1 require rails 4 (issue #114)
gem 'state_machine', '1.2.0'
gem 'validates_existence', '0.9.2'
gem 'goalie', '0.0.4'
gem 'airbrake', '4.1.0'
gem 'aws-ses', '0.6.0', require: 'aws/ses'
gem 'mysql2', '0.3.17'
gem 'doorkeeper', '2.0.1'
gem 'newrelic_rpm', '3.9.8.273'

platforms :ruby do
  gem 'RedCloth', '4.2.9', require: 'redcloth'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'therubyracer', '0.12.1'
  gem 'sass-rails', '3.2.6' # 4.0.1 for rails 4 (issue #114)
  gem 'yui-compressor', '0.12.0'
  gem 'jquery-ui-rails', '4.2.1'
  gem 'coffee-rails', '3.2.2' # 4.0.1 for rails 4 (issue #114)
  gem 'fancybox-rails', '0.2.1'
  gem 'uglifier', '2.6.0'
end

group :development do
  gem 'capistrano', '3.3.5', require: false
  gem 'capistrano-rails', require: false
  gem 'capistrano-bundler', require: false
  gem 'travis-lint'
  gem 'foreman'
  gem 'bullet'
  gem 'lol_dba'
  gem 'debugger'
end

group :test do
  gem 'mocha'
  gem 'shoulda-matchers'
  gem 'factory_girl_rails'
  gem 'simplecov'
  gem 'email_spec'
  gem 'codeclimate-test-reporter', require: nil
end

group :development, :test do
  gem 'sqlite3'
  gem 'rspec-rails'
  gem 'rspec-its'
  gem 'rspec-collection_matchers'
  gem 'guard-rspec'
  gem 'pry-rails'
  gem 'rb-fsevent', require: darwin_only('rb-fsevent')
  gem 'terminal-notifier-guard', require: darwin_only('terminal-notifier-guard')
  gem 'rb-inotify', require: linux_only('rb-inotify')
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'konacha'
  gem 'guard-konacha', git: 'https://github.com/lbeder/guard-konacha.git'
  gem 'poltergeist', require: 'capybara/poltergeist'
  gem 'selenium-webdriver'
end
