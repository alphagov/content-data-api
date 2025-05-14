# Must go at top of file
require "simplecov"
SimpleCov.start "rails"

ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)

abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rspec/rails"
require "support/authentication"
require "rake"
require "webmock/rspec"
require "gds_api/test_helpers/publishing_api"
require "pry"
require "database_cleaner"

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.include FactoryBot::Syntax::Methods
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.fixture_paths = Rails.root.join("spec/fixtures")
  config.example_status_persistence_file_path = Rails.root.join("tmp/examples.txt")
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
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
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

Dir["./spec/support/**/*.rb"].sort.each { |f| require f }
