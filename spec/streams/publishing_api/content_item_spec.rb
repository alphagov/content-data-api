RSpec.describe PublishingAPI::ContentItem do
  it "parses a valid message queue message" do
    payload = GovukSchemas::RandomExample.for_schema(notification_schema: "detailed_guide")
    item = PublishingAPI::ContentItem.parse_message(payload)

    expect(item.content_id).to eq(payload['content_id'])
    expect(item.base_path).to eq(payload['base_path'])
    expect(item.locale).to eq(payload['locale'])
    expect(item.payload_version).to eq(payload['payload_version'])
    expect(item.details).to eq(payload['details'])
    expect(item.links).to eq(payload['expanded_links'])
    expect(item.metadata[:title]).to eq(payload['title'])
  end

  it "rejects an invalid message queue message" do
    payload = { "content_id": "fake-content" }
    expect { PublishingAPI::ContentItem.parse_message(payload) }.to raise_error(KeyError)
  end
end
