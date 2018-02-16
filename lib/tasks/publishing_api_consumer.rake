require_relative '../publishing_api_consumer'
namespace :publishing_api do
  desc "Run worker to publishing API from rabbitmq"
  task consumer: :environment do
    GovukMessageQueueConsumer::Consumer.new(
      queue_name: "content_performance_manager",
      processor: PublisingApiConsumer.new,
      ).run
  end
end
