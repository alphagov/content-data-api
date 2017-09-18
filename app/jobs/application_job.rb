class ApplicationJob
  include Sidekiq::Worker

  # Retry for ~12 hours with exponential backoff, according to the default Sidekiq formula:
  # https://github.com/mperham/sidekiq/wiki/Error-Handling#automatic-job-retry
  MAX_RETRIES = 14

  sidekiq_options retry: MAX_RETRIES
end
