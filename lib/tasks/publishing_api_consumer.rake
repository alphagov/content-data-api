require_relative '../../app/domain/streams/publishing_api/consumer'

namespace :publishing_api do
  desc "Run worker to publishing API from rabbitmq"
  task consumer: :environment do
    begin
      GovukMessageQueueConsumer::Consumer.new(
        queue_name: "content_performance_manager",
        processor: Streams::PublishingAPI::Consumer.new,
      ).run
    rescue SignalException
      logger.info "SignalException suppressed"
    end
  end

  desc "Run worker to publishing API from rabbitmq for bulk import"
  task bulk_import_consumer: :environment do
    begin
      GovukMessageQueueConsumer::Consumer.new(
        queue_name: "content_performance_manager_govuk_importer",
        processor: Streams::PublishingAPI::Consumer.new,
      ).run
    rescue SignalException
      logger.info "SignalException suppressed"
    end
  end
end
