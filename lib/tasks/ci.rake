# frozen_string_literal: true

desc 'Task to run on CI: runs RSpec specs and Brakeman specs'
task ci: %i[spec rubocop brakeman]

namespace :ci do
  desc 'Task to run on CI: runs RSpec specs and Brakeman specs'
  task all: %i[spec rubocop brakeman]
end

task :rubocop do
  sh 'bundle exec rubocop'
end

task :brakeman do
  sh 'bundle exec brakeman -z --no-pager -4 --no-exit-on-warn'
end

task default: :'ci:all'
