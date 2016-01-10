# encoding: UTF-8
begin
  desc "Task to run on CI: runs RSpec specs and Konacha specs"
  task ci: [:spec]#, :'konacha:run']

  namespace :ci do
    desc "Task to run on CI: runs RSpec specs and Konacha specs"
    task all: [:spec]#, :'konacha:run']
  end

  task default: :'ci:all'
rescue LoadError
end
