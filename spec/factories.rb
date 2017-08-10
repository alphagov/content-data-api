require_relative "../app/models/audits/question"
require_relative "./factories/link_factory"

FactoryGirl.define do
  factory :content_item, class: Content::Item do
    transient do
      organisations nil
      primary_publishing_organisation nil
      policies nil
      policy_areas nil
    end

    sequence(:content_id) { |index| "content-id-%04i" % index }
    sequence(:title) { |index| "content-item-title-#{index}" }
    sequence(:document_type) { |index| "document_type-#{index}" }
    sequence(:base_path) { |index| "api/content/item/path-%04i" % index }
    public_updated_at { Time.now }
    locale { "en" }

    after(:create) do |content_item, evaluator|
      LinkFactory.add_organisations(content_item, evaluator.organisations)
      LinkFactory.add_primary_publishing_organisation(content_item, evaluator.primary_publishing_organisation)
      LinkFactory.add_policies(content_item, evaluator.policies)
      LinkFactory.add_policy_areas(content_item, evaluator.policy_areas)
    end

    factory :organisation do
      document_type "organisation"
    end

    factory :policy do
      document_type "policy"
    end
  end

  factory :link do
    sequence(:source_content_id) { |i| "source-#{i}" }
    sequence(:target_content_id) { |i| "target-#{i}" }
    link_type "organisations"
  end

  factory :audit, class: Audits::Audit do
    content_item
    user
  end

  factory :boolean_question, class: Audits::BooleanQuestion do
    sequence(:text) { |i| "BooleanQuestion #{i}" }
  end

  factory :free_text_question, class: Audits::FreeTextQuestion do
    sequence(:text) { |i| "FreeTextQuestion #{i}" }
  end

  factory :response, class: Audits::Response do
    audit
    question factory: :boolean_question
    value "true"
  end

  factory :inventory_rule do
    subtheme
    sequence(:link_type) { |i| "link-type-#{i}" }
    sequence(:target_content_id) { |i| "target-content-id-#{i}" }
  end

  factory :theme, class: Audits::Theme do
    sequence(:name) { |i| "Theme #{i}" }
  end

  factory :subtheme, class: Audits::Subtheme do
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
