set :rails_env,           "production"
set :keep_releases,       5

set :user,                "agile_brazil"
# set :password,          "Please ask to have your SSH public key added instead"

set :domain,              "ftp.dtsato.com"
set :project,             "agilebrazil2010"
set :application,         "agilebrazil2010.dtsato.com"
set :applicationdir,      "/home/#{user}/#{application}"
set :gem_path,            "/home/#{user}/gems"

set :scm,                 :git
set :repository,          "git@github.com:frankmt/agile_brazil.git"
set :scm_verbose,         true

set :deploy_to,           applicationdir
set :deploy_via,          :remote_cache

role :app, domain
role :web, domain
role :db,  domain, :primary => true

set :use_sudo, false

set :migrate_env, "GEM_PATH=#{gem_path}"
