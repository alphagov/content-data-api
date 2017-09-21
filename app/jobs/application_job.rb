require 'gds_api/exceptions'
require 'google/apis/analyticsreporting_v4'

class ApplicationJob
  include Sidekiq::Worker

  # List of errors to retry without alerting Sentry until their final retry
  ERRORS_TO_RETRY_WITHOUT_ALERTS = [
    Google::Apis::ServerError,
    Google::Apis::TransmissionError,
    GdsApi::HTTPBadGateway,
    GdsApi::TimedOutException,
  ].freeze

  # Retry for ~12 hours with exponential backoff, according to the default Sidekiq formula:
  # https://github.com/mperham/sidekiq/wiki/Error-Handling#automatic-job-retry
  MAX_RETRIES = 14

  sidekiq_options retry: MAX_RETRIES

  sidekiq_retries_exhausted do |_message, error|
    GovukError.notify(error.cause) if error.is_a?(RetryableError)
  end

  def perform(*args)
    run(*args)
  rescue *ERRORS_TO_RETRY_WITHOUT_ALERTS
    raise RetryableError
  end

  def run(*_args)
    raise NotImplementedError
  end

  class RetryableError < StandardError; end
end
