RSpec.describe PublishingAPI::EventAdapter do
  subject { described_class }

  it "transform a Publising::API into a Dimensions::Item" do
    event = PublishingAPI::Event.new(
      base_path: 'the-base_path',
      content_id: 'the-content_id',
      content_purpose_document_supertype: 'the-content_purpose_document_supertype',
      content_purpose_subgroup: 'the-content_purpose_subgroup',
      content_purpose_supergroup: 'the-content_purpose_supergroup',
      details: 'the-details',
      document_type: 'the-document_type',
      first_published_at: Time.new('2018-01-01'),
      links: 'the-links',
      locale: 'the-locale',
      payload: { 'foo' => 'bar' },
      payload_version: 10,
      public_updated_at: Time.new('2018-01-02'),
      title: 'the-title'
    )

    dimension_item = subject.to_dimension_item(event)

    expect(dimension_item).to have_attributes(
      base_path: 'the-base_path',
      content_id: 'the-content_id',
      content_purpose_document_supertype: 'the-content_purpose_document_supertype',
      content_purpose_subgroup: 'the-content_purpose_subgroup',
      content_purpose_supergroup: 'the-content_purpose_supergroup',
      document_type: 'the-document_type',
      first_published_at: Time.new('2018-01-01'),
      locale: 'the-locale',
      publishing_api_payload_version: 10,
      public_updated_at: Time.new('2018-01-02'),
      title: 'the-title',
      latest: true,
      raw_json: { 'foo' => 'bar' }.to_json,
    )
  end
end
