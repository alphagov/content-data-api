GovukError.configure do |config|
  config.excluded_exceptions << "ApplicationJob::RetryableError"
end
