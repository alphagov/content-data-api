source 'https://rubygems.org'

ruby File.read(".ruby-version").chomp

# GOV.UK gems and forks
gem 'airbrake', git: 'https://github.com/alphagov/airbrake', branch: 'silence-dep-warnings-for-rails-5'
gem 'gds-api-adapters'
gem 'gds-sso'
gem 'govuk_admin_template'
gem 'govuk_sidekiq'
gem 'plek'

# third party gems
gem 'draper'
gem 'google-api-client', '~> 0.9'
gem 'httparty'
gem 'logstasher'
gem 'jbuilder'
gem 'jquery-rails'
gem 'kaminari'
gem 'pg'
gem 'puma'
gem 'rails', '~> 5.1'
gem 'sass-rails'
gem 'turbolinks'
gem 'uglifier'
gem 'unicorn'

group :development do
  gem 'web-console'
end

group :development, :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'govuk-lint'
  gem 'guard-rspec', require: false
  gem 'listen'
  gem 'byebug'
  gem 'poltergeist'
  gem 'pry-rails'
  gem 'rails-controller-testing'
  gem 'rspec-rails'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-watcher-listen'
  gem 'timecop'
  gem 'webmock'
  gem 'active_record_disabler'
end
