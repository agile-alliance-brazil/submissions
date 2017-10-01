# frozen_string_literal: true

desc 'Task to run on CI: runs RSpec specs and Konacha specs'
task ci: %i[spec codeclimate-test-reporter rubocop brakeman konacha]

namespace :ci do
  desc 'Task to run on CI: runs RSpec specs and Konacha specs'
  task all: %i[spec codeclimate-test-reporter rubocop brakeman konacha]
end

task :'codeclimate-test-reporter' do
  sh 'if [ ! -z "${CODECLIMATE_REPO_TOKEN}" ]; then\
    bundle exec codeclimate-test-reporter;\
    fi'
end

task :rubocop do
  sh 'bundle exec rubocop'
end

task :konacha do
  MY_DIR = File.expand_path(File.join(File.dirname(__FILE__), '../../'))
  ENV['PATH'] = "#{ENV['PATH']}:#{MY_DIR}/bin:#{MY_DIR}/bin/#{`uname`}"
  system("PATH=#{ENV['PATH']} bundle exec rake konacha:run")
end

task :brakeman do
  sh 'bundle exec brakeman -z --no-pager -4 --no-exit-on-warn'
end

task default: :'ci:all'
