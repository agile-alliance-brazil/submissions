set :rails_env,           "production"
set :keep_releases,       5

set :user,                "agilebrazil"
# set :password,          "Please ask to have your SSH public key added instead"

set :domain,              "agilebrazil.com"
set :project,             "submissoes"
set :application,         "submissoes.agilebrazil.com"
set :applicationdir,      "/home/#{user}/#{application}"
set :gem_home,            "#{applicationdir}/shared/bundle/ruby/1.8"
set :gem_path,            "#{gem_home}:/usr/lib/ruby/gems/1.8"
set :bundle_cmd,          "/home/#{user}/.gems/bin/bundle"
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