publishing-api-worker: bundle exec sidekiq -C ./config/sidekiq/publishing_api.yml
google-analytics-worker: bundle exec sidekiq -C ./config/sidekiq/google_analytics.yml
web: bundle exec puma -t 5:5 -p ${PORT:-3000} -e ${RACK_ENV:-development}
