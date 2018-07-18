FactoryBot.define do
  factory :dimensions_item, class: Dimensions::Item do
    latest true
    locale 'en'
    sequence(:content_id) { |i| "content_id - #{i}" }
    sequence(:title) { |i| "title - #{i}" }
    sequence(:base_path) { |i| "link - #{i}" }
    sequence(:description) { |i| "description - #{i}" }
    sequence(:raw_json) { |i| "json - #{i}" }
    sequence(:publishing_api_payload_version)
    schema_name 'detailed_guide'
    document_type 'detailed_guide'

    initialize_with { Dimensions::Item.find_or_create_by(base_path: base_path, latest: latest) }
  end
end
