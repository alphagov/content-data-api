source 'https://rubygems.org'

ruby File.read('.ruby-version').chomp

# GOV.UK gems and forks
gem 'airbrake', git: 'https://github.com/alphagov/airbrake', branch: 'silence-dep-warnings-for-rails-5'
gem 'gds-api-adapters'
gem 'gds-sso'
gem 'govspeak'
gem 'govuk_admin_template'
gem 'govuk_sidekiq'
gem 'plek'

# Third party gems
gem 'activerecord-import'
gem 'draper'
gem 'feature'
gem 'google-api-client', '~> 0.9'
gem 'httparty'
gem 'jbuilder'
gem 'jquery-rails'
gem 'kaminari'
gem 'logstasher'
gem 'pg'
gem 'puma'
gem 'rack-proxy'
gem 'rails', '~> 5.1'
gem 'sass-rails'
gem 'selectize-rails'
gem 'turbolinks'
gem 'uglifier'
gem 'unicorn'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'web-console'
end

group :development, :test do
  gem 'active_record_disabler'
  gem 'byebug'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'govuk-lint', '~> 3.2'
  gem 'guard-rspec', require: false
  gem 'listen'
  gem 'phantomjs'
  gem 'poltergeist'
  gem 'pry-rails'
  gem 'rails-controller-testing'
  gem 'rspec-rails'
  gem 'simplecov', require: false
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-watcher-listen'
  gem 'timecop'
  gem 'webmock'
end
