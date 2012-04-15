# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'

AgileBrazil::Application.load_tasks

begin
  require 'metric_fu'
  MetricFu::Configuration.run do |config|
    config.rcov[:test_files] = ['spec/**/*_spec.rb']
    config.rcov[:rcov_opts] << "-Ispec" # Needed to find spec_helper
    config.metrics -= [:rails_best_practices]
  end

  require 'rspec'
  Rake::Task[:spec].clear
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
end

