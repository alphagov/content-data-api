# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

namespace :lint do
  task :ruby do
    sh "bundle exec govuk-lint-ruby --diff app config lib spec"
  end

  task :sass do
    sh "bundle exec govuk-lint-sass app/assets/stylesheets"
  end
end

task lint: ["lint:ruby", "lint:sass"]
task default: %i[spec lint]
