require 'govuk_message_queue_consumer/test_helpers/mock_message'

RSpec.describe PublishingAPI::Event do
  it "parses a valid message queue message" do
    payload = GovukSchemas::RandomExample.for_schema(notification_schema: "detailed_guide")
    message = GovukMessageQueueConsumer::MockMessage.new(
      payload,
      {},
      OpenStruct.new(routing_key: 'the-routing_key')
    )

    event = PublishingAPI::Event.parse(message)

    expect(event.payload).to eq(payload)
    expect(event.routing_key).to eq('the-routing_key')
  end
end
