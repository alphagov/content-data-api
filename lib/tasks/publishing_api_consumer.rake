namespace :publishing_api do
  desc "Run worker to publishing API from rabbitmq"
  task consumer: :environment do
    GovukMessageQueueConsumer::Consumer.new(
      queue_name: ENV["RABBITMQ_QUEUE"],
      processor: Streams::Consumer.new,
    ).run
  rescue SignalException
    logger.info "SignalException suppressed"
  end

  desc "Run worker to publishing API from rabbitmq for bulk import"
  task bulk_import_consumer: :environment do
    GovukMessageQueueConsumer::Consumer.new(
      queue_name: ENV["RABBITMQ_QUEUE_BULK"],
      processor: Streams::Consumer.new,
    ).run
  rescue SignalException
    logger.info "SignalException suppressed"
  end
end
