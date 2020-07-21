source "https://rubygems.org"

ruby File.read(".ruby-version").chomp

# GOV.UK gems and forks
gem "gds-api-adapters", "~> 67.0.0"
gem "gds-sso"
gem "govuk_app_config"
gem "govuk_sidekiq", "~> 3"
gem "plek"

# Third party gems
gem "active_model_serializers"
gem "activerecord-import"
gem "awesome_print"
gem "google-api-client", "~> 0.42"
gem "govuk_message_queue_consumer", "~> 3.5"
gem "httparty"
gem "jbuilder"
gem "kaminari"
gem "nokogiri", "~> 1.10"
gem "odyssey"
gem "pg"
gem "rack-proxy"
gem "rails", "~> 5.2"
gem "rails-erd"
gem "ruby-progressbar"
gem "scenic"
gem "uuid"

group :development do
  gem "better_errors"
  gem "binding_of_caller"
  gem "web-console"
end

group :development, :test do
  gem "byebug"
  gem "database_cleaner"
  gem "factory_bot_rails"
  gem "govuk_schemas", "4.0.0"
  gem "listen"
  gem "pry-byebug"
  gem "pry-rails"
  gem "rack", ">= 2.0.6"
  gem "rails-controller-testing"
  gem "rspec-its"
  gem "rspec-rails"
  gem "rubocop-govuk", "~> 3.17"
  gem "shoulda-matchers"
  gem "simplecov", require: false
  gem "spring"
  gem "spring-commands-rspec"
  gem "spring-watcher-listen"
  gem "timecop"
  gem "webmock"
end
