# encoding: UTF-8
# This file is copied to spec/ when you run 'rails generate rspec:install'

ENV['RAILS_ENV'] ||= 'test'
require 'simplecov'
SimpleCov.start 'rails' do
  add_group 'Workers', 'app/workers'
  add_group 'Services', 'app/services'
  add_group 'Uploaders', 'app/uploaders'
  minimum_coverage 89
end
# make it possible to merge reports under spring
SimpleCov.command_name 'RSpec'

require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'rspec/collection_matchers'
require 'cancan/matchers'
require 'paperclip/matchers'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[::Rails.root.join('spec/support/**/*.rb')].each {|f| require f}

::Rails.logger.level = 4

module Airbrake
  def self.notify(thing)
    # do nothing.
  end
end

# Checks for pending migration and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.include(ControllerMacros, type: :controller)
  config.include(DisableAuthorization, type: :controller)
  config.include(Devise::Test::ControllerHelpers, type: :controller)
  config.include(EmailSpec::Helpers, type: :mailer)
  config.include(EmailSpec::Matchers, type: :mailer)
  config.include(TrimmerMacros)
  config.include(Paperclip::Shoulda::Matchers, type: :model)
  config.include(ValidatesExistenceMacros)

  config.expect_with :rspec, :minitest
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  # config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_examples = true
  config.use_instantiated_fixtures = false

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    # Choose a test framework:
    with.test_framework :rspec
    # with.test_framework :minitest
    # with.test_framework :minitest_4
    # with.test_framework :test_unit

    # Choose one or more libraries:
    # with.library :active_record
    # with.library :active_model
    # with.library :action_controller
    # Or, choose the following (which implies all of the above):
    with.library :rails
  end
end
