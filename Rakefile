# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"

Rails.application.load_tasks

desc "Lint ruby files"
task lint: :environment do
  sh "bundle exec rubocop --parallel app config lib spec"
end

task default: %i[spec lint]
