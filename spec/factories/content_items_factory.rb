FactoryGirl.define do
  factory :content_item do
    sequence(:id) { |index| index }
    sequence(:content_id) { |index| "content-id-#{index}" }
    sequence(:title) { |index| "title-#{index}" }
    sequence(:document_type) { |index| "document_type-#{index}" }
    base_path "api/content/item/path"
    public_updated_at { Time.now }

    factory :content_item_with_organisations do
      transient do
        organisations_count 1
      end
      after(:create) do |content_item, evaluator|
        create_list(:organisation, evaluator.organisations_count, content_items: [content_item])
      end
    end
  end
end
