# frozen_string_literal: true

desc 'Task to run on CI: runs RSpec specs and Brakeman specs'
task ci: %i[spec codeclimate-test-reporter rubocop brakeman]

namespace :ci do
  desc 'Task to run on CI: runs RSpec specs and Brakeman specs'
  task all: %i[spec codeclimate-test-reporter rubocop brakeman]
end

task :'codeclimate-test-reporter' do
  sh 'if [ ! -z "${CODECLIMATE_REPO_TOKEN}" ]; then\
    bundle exec codeclimate-test-reporter;\
    fi'
end

task :rubocop do
  sh 'bundle exec rubocop'
end

task :brakeman do
  sh 'bundle exec brakeman -z --no-pager -4 --no-exit-on-warn'
end

task default: :'ci:all'
