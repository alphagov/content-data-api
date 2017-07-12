source 'https://rubygems.org'

ruby File.read('.ruby-version').chomp

# GOV.UK gems and forks
gem 'airbrake', git: 'https://github.com/alphagov/airbrake', branch: 'silence-dep-warnings-for-rails-5'
gem 'gds-api-adapters'
gem 'gds-sso'
gem 'govspeak', '~> 5.0.3'
gem 'govuk_admin_template'
gem 'govuk_sidekiq'
gem 'plek'

# Third party gems
gem 'draper'
gem 'google-api-client', '~> 0.9'
gem 'httparty'
gem 'jbuilder'
gem 'jquery-rails'
gem 'kaminari'
gem 'logstasher'
gem 'pg'
gem 'puma'
gem 'rails', '~> 5.1'
gem 'sass-rails'
gem 'selectize-rails'
gem 'turbolinks'
gem 'uglifier'
gem 'unicorn'
gem 'rack-proxy'

group :development do
  gem 'web-console'
end

group :development, :test do
  gem 'active_record_disabler'
  gem 'byebug'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'phantomjs'
  gem 'factory_girl_rails'
  gem 'govuk-lint'
  gem 'guard-rspec', require: false
  gem 'listen'
  gem 'poltergeist'
  gem 'pry-rails'
  gem 'rails-controller-testing'
  gem 'rspec-rails'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-watcher-listen'
  gem 'timecop'
  gem 'webmock'
end
