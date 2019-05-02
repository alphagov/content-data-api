require_relative '../../app/domain/streams/consumer'

def consume_from(queue_name)
  begin
    consumers = []

    3.times do
      consumers << GovukMessageQueueConsumer::Consumer.new(
        queue_name: queue_name,
        processor: Streams::Consumer.new,
      ).run(subscribe_opts: { block: false })
    end

    sleep 10 until consumers.all? { |c| c.channel.closed? }
  rescue SignalException
    logger.info "SignalException suppressed"
  end
end

namespace :publishing_api do
  desc "Run worker to publishing API from rabbitmq"
  task consumer: :environment do
    consume_from(ENV['RABBITMQ_QUEUE'])
  end

  desc "Run worker to publishing API from rabbitmq for bulk import"
  task bulk_import_consumer: :environment do
    consume_from(ENV['RABBITMQ_QUEUE_BULK'])
  end
end
