if ENV['ERRBIT_API_KEY'].present?
  errbit_uri = Plek.find_uri('errbit')

  Airbrake.configure do |config|
    config.api_key = ENV['ERRBIT_API_KEY']
    config.host = errbit_uri.host
    config.secure = errbit_uri.scheme == 'https'
    config.environment_name = ENV['ERRBIT_ENVIRONMENT_NAME']

    # If we're retrying a job in Sidekiq, then only log the error on the final retry
    config.ignore_by_filter do |exception_data|
      parameters = exception_data[:parameters].deep_symbolize_keys || {}
      retry_count = parameters.dig(:job, :retry_count)
      retry_count.present? && retry_count.to_i < ApplicationJob::MAX_RETRIES
    end
  end
end
