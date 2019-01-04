source 'https://rubygems.org'

ruby File.read('.ruby-version').chomp

# GOV.UK gems and forks
gem 'gds-api-adapters', '~> 55.0.2'
gem 'gds-sso'
gem 'govuk_admin_template', '~> 6.5'
gem 'govuk_app_config'
gem 'govuk_sidekiq', '~> 3'
gem 'plek'

# Third party gems
gem 'activerecord-import'
gem 'active_model_serializers'
gem 'awesome_print'
gem 'chartkick'
gem 'google-api-client', '~> 0.27'
gem 'govuk_message_queue_consumer', '~> 3.2'
gem 'httparty'
gem 'jbuilder'
gem 'jquery-rails'
gem 'kaminari'
gem 'nokogiri', '~> 1.9'
gem 'odyssey'
gem 'pg'
gem 'puma'
gem 'rack-proxy'
gem 'rails', '~> 5.2'
gem 'ruby-progressbar'
gem 'sass-rails'
gem 'scenic'
gem 'uglifier'
gem 'unicorn'
gem 'uuid'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'web-console'
end

group :test do
  # This is a dependency for Teaspoon and a known issue
  # See https://github.com/jejacks0n/teaspoon/issues/405
  gem 'coffee-script'
end

group :development, :test do
  gem 'byebug'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'govuk-lint', '3.10.0'
  gem 'govuk_schemas', '3.2.0'
  gem 'guard-rspec', require: false
  gem 'listen'
  gem 'phantomjs'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rails-controller-testing'
  gem "rack", ">= 2.0.6"
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-watcher-listen'
  gem 'timecop'
  gem 'webmock'
end
