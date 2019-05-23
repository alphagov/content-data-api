require_relative '../../app/domain/streams/consumer'

def setup_consumers(queue_name, number_of_consumers)
  Array.new(number_of_consumers) do
    GovukMessageQueueConsumer::Consumer.new(
      queue_name: queue_name,
      processor: Streams::Consumer.new,
    ).run(subscribe_opts: { block: false })
  end
end

def consume_forever_from(queue_name)
  begin
    consumers = setup_consumers(queue_name, 3)

    sleep 10 until consumers.all? { |c| c.channel.closed? }
  rescue SignalException
    logger.info "SignalException suppressed"
  end
end

def consume_until_empty_from(queue_name)
  begin
    consumers = setup_consumers(queue_name, 1)

    sleep 10 while consumers.all? { |c| c.queue.message_count.positive? }
  rescue SignalException
    logger.info "SignalException suppressed"
  end
end

namespace :publishing_api do
  desc "Run worker to publishing API from rabbitmq"
  task consumer: :environment do
    consume_forever_from(ENV['RABBITMQ_QUEUE'])
  end

  desc "Run worker to publishing API from rabbitmq for bulk import"
  task bulk_import_consumer: :environment do
    consume_forever_from(ENV['RABBITMQ_QUEUE_BULK'])
  end

  desc "Run consumers to re-process the dead letter queue"
  task dead_letter_consumer: :environment do
    consume_until_empty_from(ENV['RABBITMQ_QUEUE_DEAD'])
  end
end
