# Load DSL and Setup Up Stages
require 'capistrano/setup'

# Includes default deployment tasks
require 'capistrano/deploy'

# Includes tasks from other gems included in your Gemfile
#
# For documentation on these, see for example:
#
#   https://github.com/capistrano/rvm
#   https://github.com/capistrano/rbenv
#   https://github.com/capistrano/chruby
#   https://github.com/capistrano/bundler
#   https://github.com/capistrano/rails
#
# require 'capistrano/rvm'
# require 'capistrano/rbenv'
# require 'capistrano/chruby'
require 'capistrano/bundler'
require 'capistrano/rails/assets'
require 'capistrano/rails/migrations'

# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
Dir.glob('lib/capistrano/tasks/*.cap').each { |r| import r }

before "bundler:install", "deploy:puppet"

namespace :deploy do
  %w(start restart).each do |name|
    desc "#{name.capitalize} application"
    task name.to_sym do
      on roles(:app), in: :sequence, wait: 5 do
        execute :touch, release_path.join('tmp/restart.txt')
      end
    end
  end

  after :publishing, :restart

  task :puppet do
    on roles(:all) do |host|
      within release_path.join('puppet') do
        execute :'librarian-puppet', :install
      end
      within release_path do
        execute :sudo, :puppet, 'apply', '--modulepath /etc/puppet/modules:puppet/modules', "puppet/manifests/#{fetch(:manifest)}.pp"
      end
    end
  end
end
