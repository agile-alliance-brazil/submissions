require 'capistrano/ext/multistage'
require "bundler/capistrano"

after "deploy:update_code", "deploy:symlink_configs"
after "deploy:update_code", "deploy:compile_sass"

after "deploy:symlink",     "deploy:package_assets"

after "deploy",             "deploy:cleanup"
after "deploy:migrations",  "deploy:cleanup"

namespace :passenger do
  desc "Restart Application"
  task :restart, :roles => :app do
    run <<-CMD
      touch #{current_path}/tmp/restart.txt
    CMD
  end
end

namespace :deploy do
  %w(start restart).each do |name|
    task name, :roles => :app do
      passenger.restart
    end
  end
  
  task :compile_sass, :roles => :app, :except => {:no_release => true} do
    rails_env = fetch(:rails_env, "production")
    run "#{release_path}/script/rails runner -e #{rails_env} 'Sass::Plugin.update_stylesheets'"
  end
  
  task :package_assets, :roles => :app, :except => {:no_release => true} do
    bundle_cmd = fetch(:bundle_cmd, "bundle")
    run "cd #{current_path} && #{bundle_cmd} exec jammit -f"
  end

  task :symlink_configs, :roles => :app, :except => {:no_release => true} do
    run <<-CMD
      cd #{release_path} &&
      ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml &&
      ln -nfs #{shared_path}/config/config.yml #{release_path}/config/config.yml
    CMD
  end
end

set :stages, %w(staging production)
set :default_stage, "staging"

# NOTE: As of Capistrano 2.1, anyone using Windows should allocate a PTY explicitly.
# Otherwise, you will see command prompts (such as requests for SVN passwords) act funny.
default_run_options[:pty] = true
        require './config/boot'
        require 'hoptoad_notifier/capistrano'
