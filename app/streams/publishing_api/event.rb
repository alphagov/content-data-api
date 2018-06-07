# https://github.com/alphagov/publishing-api/blob/master/doc/rabbitmq.md#event_type
class PublishingAPI::Event
  include ActiveModel::Model

  attr_accessor :payload
  attr_accessor :routing_key

  def self.parse(message)
    payload = message.payload
    routing_key = message.delivery_info.routing_key

    new(
      payload: payload,
      routing_key: routing_key,
    )
  end
end


