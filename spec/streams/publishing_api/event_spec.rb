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

    expect(event.base_path).to eq(payload['base_path'])
    expect(event.content_id).to eq(payload['content_id'])
    expect(event.content_purpose_document_supertype).to eq(payload['content_purpose_document_supertype'])
    expect(event.content_purpose_subgroup).to eq(payload['content_purpose_subgroup'])
    expect(event.content_purpose_supergroup).to eq(payload['content_purpose_supergroup'])
    expect(event.details).to eq(payload['details'])
    expect(event.document_type).to eq(payload['document_type'])
    expect(event.first_published_at).to eq(Time.parse(payload['first_published_at']))
    expect(event.links).to eq(payload['expanded_links'])
    expect(event.locale).to eq(payload['locale'])
    expect(event.payload).to eq(payload)
    expect(event.payload_version).to eq(payload['payload_version'])
    expect(event.routing_key).to eq('the-routing_key')
    expect(event.public_updated_at).to eq(Time.parse(payload['public_updated_at']))
    expect(event.title).to eq(payload['title'])
  end

  it "rejects an invalid message queue message" do
    payload = { "content_id": "fake-content" }
    message = GovukMessageQueueConsumer::MockMessage.new(payload)
    expect { PublishingAPI::Event.parse(message) }.to raise_error(KeyError)
  end
end
