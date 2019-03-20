require_relative '../../app/domain/streams/consumer'

# This is just useful when changing Content Performance Manager to the
# Content Data API, and can be removed afterwards
def app_name
  ENV.fetch('GOVUK_APP_NAME', 'content-performance-manager')
end

namespace :publishing_api do
  desc "Run worker to publishing API from rabbitmq"
  task consumer: :environment do
    begin
      GovukMessageQueueConsumer::Consumer.new(
        queue_name: app_name.underscore,
        processor: Streams::Consumer.new,
      ).run
    rescue SignalException
      logger.info "SignalException suppressed"
    end
  end

  desc "Run worker to publishing API from rabbitmq for bulk import"
  task bulk_import_consumer: :environment do
    begin
      GovukMessageQueueConsumer::Consumer.new(
        queue_name: "#{app_name.underscore}_govuk_importer",
        processor: Streams::Consumer.new,
      ).run
    rescue SignalException
      logger.info "SignalException suppressed"
    end
  end
end
