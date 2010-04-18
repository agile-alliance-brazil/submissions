# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'

begin
  vendored_seed_fu_dir = Dir["#{RAILS_ROOT}/vendor/gems/seed-fu*"].first
  load "#{vendored_seed_fu_dir}/tasks/seed_fu_tasks.rake"
rescue LoadError
  # seed-fu gem is not installed
end

begin
  require(File.join(RAILS_ROOT, 'vendor', 'gems', 'metric_fu-1.1.6', 'lib', 'metric_fu'))
rescue
  # metric_fu gem is not installed
end
