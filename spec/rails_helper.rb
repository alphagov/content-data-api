# Run code coverage reporting on Jenkins
if ENV["TEST_COVERAGE"] == "true"
  require 'simplecov'
  SimpleCov.start 'rails'
end

ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../../config/environment", __FILE__)

abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rspec/rails"
require "support/authentication"
require "support/google_analytics_factory"
require "webmock/rspec"
require "capybara/poltergeist"
require "gds_api/test_helpers/publishing_api_v2"
require "pry"
require "database_cleaner"
require "site_prism"

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.include FactoryBot::Syntax::Methods
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.fixture_path = "#{Rails.root}/spec/fixtures"
  config.example_status_persistence_file_path = "#{Rails.root}/tmp/examples.txt"
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.use_transactional_fixtures = false
  config.mock_with(:rspec) { |m| m.verify_partial_doubles = true }
  config.expect_with :rspec do |e|
    e.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.before(:suite) do
    ActiveRecord::Migration.maintain_test_schema!
    Rails.application.load_tasks
    WebMock.disable_net_connect!(allow_localhost: true)
    Capybara.javascript_driver = :poltergeist
    DatabaseCleaner.clean_with(:truncation)
  end

  def use_truncation?
    Capybara.current_driver != :rack_test
  end

  config.before(:each) do
    DatabaseCleaner.strategy = use_truncation? ? :truncation : :transaction
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.library :rails
    with.test_framework :rspec
  end
end

SitePrism.configure do |config|
  config.use_implicit_waits = true
end

Dir['./spec/support/**/*.rb'].sort.each { |f| require f }
