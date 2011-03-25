source 'http://rubygems.org'

gem 'rails', '3.0.3'

gem 'haml'
gem 'will_paginate', "~> 3.0.pre2"
gem 'formtastic'
gem 'inherited_resources'
gem 'responders'
gem 'has_scope'
gem 'devise'
gem 'brhelper'
gem 'seed-fu'
gem 'acts-as-taggable-on'
gem 'cancan'
gem 'acts_as_commentable'
gem 'state_machine'
gem 'validates_existence', :git => 'git://github.com/dtsato/validates_existence.git'
gem 'goalie'
gem 'jammit'

platforms :mswin, :mingw do
  gem 'RedCloth', :require => 'redcloth', :platforms => :mswin
end

platforms :ruby do
  gem 'RedCloth', :require => 'redcloth'
end

group :development, :test do
  gem 'hoe', '=2.8.0'
end

group :development do
  gem 'sqlite3-ruby', :require => 'sqlite3'
  gem 'ruby-mysql'
  gem 'capistrano-ext'
end

group :development, :test do
  gem 'mocha'
  gem 'rspec-rails'
  gem 'remarkable_activerecord', '~>4.0.0.alpha4'
  gem 'factory_girl_rails'
  gem 'metric_fu'
  gem 'hoe', '=2.8.0'
end