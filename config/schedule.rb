# default cron env is "/usr/bin:/bin" which is not sufficient as
# govuk_env is in /usr/local/bin
env :PATH, '/usr/local/bin:/usr/bin:/bin'
set :output, error: 'log/cron.error.log', standard: 'log/cron.log'
job_type :rake, 'cd :path && /usr/local/bin/govuk_setenv content-performance-manager bundle exec rake :task :output'

every :day, at: '2am' do
  rake 'import:all_content_items'
end
