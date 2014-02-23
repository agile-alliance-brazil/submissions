# encoding: UTF-8
set :rails_env,           "production"
set :keep_releases,       1

set :user,                "vagrant"
# set :password,          "run `vagrant ssh-config deploy >> ~/.ssh/config` before trying to deploy"

set :domain,              "10.11.12.16"
set :project,             "submissions"
set :application,         "submissions"
set :applicationdir,      "/srv/apps/#{application}"
set :bundle_cmd,          "/usr/local/bin/bundle"
set :rake,                "#{bundle_cmd} exec rake"
set :manifest,            "vagrant"

set :scm,                 :none
set :repository,          "#{File.join(File.dirname(__FILE__), '/../../')}"
set :scm_verbose,         true

set :deploy_to,           applicationdir
set :deploy_via,          :copy

role :app, domain
role :web, domain
role :db,  domain, :primary => true

set :use_sudo, false
