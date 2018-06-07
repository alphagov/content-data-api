RSpec.describe PublishingAPI::ContentItem do
  it "parses a valid message queue message" do
    payload = GovukSchemas::RandomExample.for_schema(notification_schema: "detailed_guide")
    content_item = PublishingAPI::ContentItem.parse(payload: payload)

    expect(content_item.base_path).to eq(payload['base_path'])
    expect(content_item.content_id).to eq(payload['content_id'])
    expect(content_item.content_purpose_document_supertype).to eq(payload['content_purpose_document_supertype'])
    expect(content_item.content_purpose_subgroup).to eq(payload['content_purpose_subgroup'])
    expect(content_item.content_purpose_supergroup).to eq(payload['content_purpose_supergroup'])
    expect(content_item.details).to eq(payload['details'])
    expect(content_item.document_type).to eq(payload['document_type'])
    expect(content_item.first_published_at).to eq(Time.parse(payload['first_published_at']))
    expect(content_item.links).to eq(payload['expanded_links'])
    expect(content_item.locale).to eq(payload['locale'])
    expect(content_item.payload).to eq(payload)
    expect(content_item.payload_version).to eq(payload['payload_version'])
    expect(content_item.public_updated_at).to eq(Time.parse(payload['public_updated_at']))
    expect(content_item.title).to eq(payload['title'])
  end

  it "rejects an invalid message queue message" do
    payload = { "content_id": "fake-content" }
    expect { PublishingAPI::ContentItem.parse(payload: payload) }.to raise_error(KeyError)
  end
end
