default-worker: bundle exec sidekiq -C config/sidekiq.yml
publishing-api-consumer: bundle exec rake publishing_api:consumer
bulk-import-publishing-api-consumer: bundle exec rake publishing_api:bulk_import_consumer
web: bundle exec puma -t 5:5 -p ${PORT:-3000} -e ${RACK_ENV:-development}
