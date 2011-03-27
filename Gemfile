source 'http://rubygems.org'

gem 'rails', '3.0.3'
gem 'rack', '=1.2.2'
gem 'haml', '~> 3.0.25'
gem 'will_paginate', '~> 3.0.pre2'
gem 'formtastic', '~> 1.2.3'
gem 'inherited_resources', '~> 1.2.1'
gem 'responders', '~> 0.6.2'
gem 'has_scope', '~> 0.5.0'
gem 'devise', '~> 1.1.8'
gem 'brhelper', '~> 3.0.4'
gem 'seed-fu', '~> 2.0.1'
gem 'acts-as-taggable-on', '~> 2.0.6'
gem 'cancan', '~> 1.6.1'
gem 'acts_as_commentable', '~> 3.0.1'
gem 'state_machine', '~> 0.9.4'
gem 'validates_existence', :git => 'git://github.com/dtsato/validates_existence.git'
gem 'goalie', '~> 0.0.4'
gem 'jammit', '~> 0.6.0'

platforms :mswin, :mingw do
  gem 'RedCloth', '~> 4.2.7', :require => 'redcloth', :platforms => :mswin
end

platforms :ruby do
  gem 'RedCloth', '~> 4.2.7', :require => 'redcloth'
end

group :development do
  gem 'sqlite3-ruby', '~> 1.3.3', :require => 'sqlite3'
  gem 'ruby-mysql', '~> 2.9.4'
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