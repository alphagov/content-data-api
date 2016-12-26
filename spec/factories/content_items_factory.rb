FactoryGirl.define do
  factory :content_item do
    sequence(:id) { |index| index }
    sequence(:content_id) { |index| "content-id-#{index}" }
    sequence(:title) { |index| "title-#{index}" }
    sequence(:document_type) { |index| "document_type-#{index}" }
    link "api/content/item/path"
    public_updated_at { Time.now }
  end
end
