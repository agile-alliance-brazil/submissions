begin
  require 'guard/jasmine/task'
  Guard::JasmineTask.new

  desc "Task to run on CI: runs RSpec specs and Jasmine specs"
  task :ci => [:spec, :"guard:jasmine"]

  task :default => :ci
rescue LoadError
end