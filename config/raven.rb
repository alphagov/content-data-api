Raven.configure do |config|
  config.excluded_exceptions << "Content::Jobs::ApplicationJob::RetryableError"
end
