RSpec.describe PublishingAPI::Promotion do
  ATTRIBUTE_NAMES =
    %w(
      analytics_identifier
      content_purpose_document_supertype
      content_purpose_subgroup
      content_purpose_supergroup
      description
      document_text
      document_type
      first_published_at
      locale
      phase
      previous_version
      primary_organisation_content_id
      primary_organisation_title
      primary_organisation_withdrawn
      public_updated_at
      publishing_api_payload_version
      publishing_app
      raw_json
      rendering_app
      schema_name
      title
      update_type
    ).freeze

  ATTRIBUTE_NAMES.each do |attribute_name|
    it "returns true if the #{attribute_name} has changed" do
      item1 = build :dimensions_item, attribute_name => 'value-1'
      item2 = build :dimensions_item, attribute_name => 'value-2'

      promotion = PublishingAPI::Promotion.new(item1, item2)
      expect(promotion.valid?).to be true
    end
  end

  it 'does not include the latest attribute' do
    item1 = build :dimensions_item, latest: true
    item2 = build :dimensions_item, item1.attributes.dup
    item2.latest = false

    promotion = PublishingAPI::Promotion.new(item1, item2)
    expect(promotion.valid?).to be false
  end

  it 'returns true if old_item is nil' do
    item1 = build :dimensions_item
    item2 = nil

    promotion = PublishingAPI::Promotion.new(item1, item2)
    expect(promotion.valid?).to be true
  end
end
