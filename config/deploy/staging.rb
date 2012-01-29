set :rails_env,           "production"
set :keep_releases,       5

set :user,                "agile_brazil"
# set :password,          "Please ask to have your SSH public key added instead"

set :domain,              "ftp.dtsato.com"
set :project,             "agilebrazil"
set :application,         "agilebrazil.dtsato.com"
set :applicationdir,      "/home/#{user}/#{application}"
# set :gem_path,            "/home/#{user}/.gems"
set :bundle_cmd,          "#{gem_path}/bin/bundle"
set :rake,                "#{bundle_cmd} exec rake"

set :scm,                 :git
set :repository,          "git@github.com:dtsato/agile_brazil.git"
set :scm_verbose,         true

set :deploy_to,           applicationdir
set :deploy_via,          :remote_cache

role :app, domain
role :web, domain
role :db,  domain, :primary => true

set :use_sudo, false