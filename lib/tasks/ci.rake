# encoding: UTF-8
begin
  desc "Task to run on CI: runs RSpec specs and Konacha specs"
  task ci: %i(spec codeclimate-test-reporter)# konacha:run)

  namespace :ci do
    desc "Task to run on CI: runs RSpec specs and Konacha specs"
    task all: %i(spec codeclimate-test-reporter)# konacha:run)
  end

  task :'codeclimate-test-reporter' do
    sh 'if [[ -n ${CODECLIMATE_REPO_TOKEN} ]]; then\
      bundle exec codeclimate-test-reporter;\
      fi'
  end

  task default: :'ci:all'
rescue LoadError
end
