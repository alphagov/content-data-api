require_relative "../app/models/question"

FactoryGirl.define do
  factory :content_item do
    sequence(:content_id) { |index| "content-id-#{index}" }
    sequence(:title) { |index| "content-item-title-#{index}" }
    sequence(:document_type) { |index| "document_type-#{index}" }
    base_path "api/content/item/path"
    public_updated_at { Time.now }
  end

  factory :link do
    sequence(:source_content_id) { |i| "source-#{i}" }
    sequence(:target_content_id) { |i| "target-#{i}" }
    link_type "organisations"
  end

  factory :audit do
    content_item
    user
  end

  factory :boolean_question, class: BooleanQuestion do
    sequence(:text) { |i| "BooleanQuestion #{i}" }
  end

  factory :free_text_question, class: FreeTextQuestion do
    sequence(:text) { |i| "FreeTextQuestion #{i}" }
  end

  factory :response do
    audit
    question factory: :boolean_question
    value "true"
  end

  factory :inventory_rule do
    subtheme
    sequence(:link_type) { |i| "link-type-#{i}" }
    sequence(:target_content_id) { |i| "target-content-id-#{i}" }
  end

  factory :theme do
    sequence(:name) { |i| "Theme #{i}" }
  end

  factory :subtheme do
    theme
    sequence(:name) { |i| "Subtheme #{i}" }
  end

  factory :user do
    sequence(:uid) { |i| "user-#{i}" }
    name 'Test User'
    email 'user@example.com'
    permissions { ['signin'] }
    organisation_slug "government-digital-service"
  end

  factory :group do
    sequence(:slug) { |index| "slug-#{index}" }
    sequence(:name) { |index| "name-#{index}" }
    sequence(:group_type) { |index| "group-type-#{index}" }

    trait :with_two_content_items do
      after(:create) do |group|
        group.content_items = create_list(:content_item, 2)
      end
    end

    trait :with_one_content_item do
      after(:create) do |group|
        group.content_items << create(:content_item)
      end
    end
  end
end
