FactoryBot.define do
  factory :edition, class: Dimensions::Item do
    latest { true }
    locale { 'en' }
    sequence(:content_id) { |i| "content_id - #{i}" }
    sequence(:title) { |i| "title - #{i}" }
    sequence(:base_path) { |i| "link - #{i}" }
    sequence(:description) { |i| "description - #{i}" }
    sequence(:publishing_api_payload_version)
    schema_name { 'detailed_guide' }
    document_type { 'detailed_guide' }
    warehouse_item_id { "#{content_id}:#{locale}" }
    transient do
      date { Time.zone.today }
      replaces { nil }
    end
    to_create do |new_edition, evaluator|
      if evaluator.replaces
        new_edition.promote! evaluator.replaces
      else
        new_edition.save!
      end
    end
  end
end
