require_relative '../../app/domain/streams/consumer'

namespace :publishing_api do
  desc "Run worker to publishing API from rabbitmq"
  task consumer: :environment do
    begin
      GovukMessageQueueConsumer::Consumer.new(
        queue_name: 'content_data_api',
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
        queue_name: 'content_data_api_govuk_importer',
        processor: Streams::Consumer.new,
      ).run
    rescue SignalException
      logger.info "SignalException suppressed"
    end
  end
end
