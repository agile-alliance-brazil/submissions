# encoding: UTF-8
begin
  require 'guard/jasmine/task'
  Guard::JasmineTask.new

  desc "Task to run on CI: runs RSpec specs"
  task :ci => [:spec]

  namespace :ci do
    desc "Task to run on CI: runs RSpec specs and Jasmine tests"
    task :all => [:spec, :'guard:jasmine']
  end

  task :default => :'ci:all'
rescue LoadError
end