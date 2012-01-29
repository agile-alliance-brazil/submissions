source 'http://rubygems.org'

gem 'rails', '3.0.7'
gem 'jquery-rails'
gem 'rack', '=1.2.1'
gem 'haml', '~> 3.0.25'
gem 'will_paginate', '~> 3.0.pre2'
# this was ~> 1.2.3, but there's a bug with checkboxes that should be fixed with 1.2.4
# https://github.com/justinfrench/formtastic/commit/a36408d4ea805d7c20296c07b5c7733dab77acc9
gem 'formtastic', :git => 'git://github.com/justinfrench/formtastic.git', :branch => '1.2-stable'
gem 'inherited_resources', '~> 1.2.1'
gem 'responders', '~> 0.6.2'
gem 'has_scope', '~> 0.5.0'
gem 'devise', '~> 1.1.8'
gem 'brhelper', '~> 3.0.4'
gem 'brcpfcnpj', '~> 3.0.4'
gem 'seed-fu', '~> 2.0.1'
gem 'acts-as-taggable-on', '~> 2.0.6'
gem 'cancan', '~> 1.6.1'
gem 'acts_as_commentable', '~> 3.0.1'
gem 'state_machine', '~> 0.9.4'
gem 'validates_existence', '~> 0.7.1'
gem 'goalie', '~> 0.0.4'
gem 'jammit', '~> 0.6.0'
gem 'fastercsv', '~> 1.5.4'
gem 'hoptoad_notifier', '~> 2.4.8'
gem 'aws-ses', '~> 0.4.2', :require => 'aws/ses'
gem 'mysql2', '~> 0.2.7'

platforms :mswin, :mingw do
  gem 'RedCloth', '~> 4.2.7', :require => 'redcloth', :platforms => :mswin
end

platforms :ruby do
  gem 'RedCloth', '~> 4.2.7', :require => 'redcloth'
end

group :development do
  gem 'sqlite3-ruby', '~> 1.3.3', :require => 'sqlite3'
  gem 'capistrano-ext', '~> 1.2.1'
end

group :development, :test do
  gem 'mocha', '~> 0.9.12'
  gem 'rspec-rails', '~> 2.5.0'
  gem 'remarkable_activerecord', '~>4.0.0.alpha4'
  gem 'factory_girl_rails', '~> 1.0.1'
  gem 'metric_fu', '~> 2.1.1'
  gem 'hoe', '=2.8.0'
end