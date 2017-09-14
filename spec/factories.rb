require_relative "./factories/link_factory"

FactoryGirl.define do
  factory :content_item, class: Content::Item do
    transient do
      allocated_to nil
      organisations nil
      primary_publishing_organisation nil
      policies nil
      policy_areas nil
    end

    sequence(:content_id) { |index| "content-id-%04i" % index }
    sequence(:title) { |index| "content-item-title-#{index}" }
    document_type { Audits::Plan.document_type_ids.sample }
    sequence(:base_path) { |index| "api/content/item/path-%04i" % index }
    public_updated_at { Time.now }
    locale { "en" }

    after(:create) do |content_item, evaluator|
      LinkFactory.add_organisations(content_item, evaluator.organisations)
      LinkFactory.add_primary_publishing_organisation(content_item, evaluator.primary_publishing_organisation)
      LinkFactory.add_policies(content_item, evaluator.policies)
      LinkFactory.add_policy_areas(content_item, evaluator.policy_areas)
      create(:allocation, content_item: content_item, user: evaluator.allocated_to) unless evaluator.allocated_to.nil?
    end

    factory :organisation do
      document_type "organisation"
    end

    factory :policy do
      document_type "policy"
    end
  end

  factory :link, class: Content::Link do
    sequence(:source_content_id) { |i| "source-#{i}" }
    sequence(:target_content_id) { |i| "target-#{i}" }
    link_type "organisations"
  end

  factory :audit, aliases: %i(passing_audit), class: Audits::Audit do
    content_item
    user

    change_attachments false
    change_body false
    change_description false
    change_title false
    outdated false
    redundant false
    reformat false
    similar false

    factory :failing_audit do
      redundant true
    end
  end

  factory :allocation, class: Audits::Allocation do
    content_item
    user
  end

  factory :user do
    sequence(:uid) { |i| "user-#{i}" }
    sequence(:name) { |i| "Test User #{i}" }
    email 'user@example.com'
    permissions { ['signin'] }
    organisation_slug "government-digital-service"

    trait :with_allocated_content do
      after(:create) do |user|
        create :allocation, user: user
      end
    end
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

  factory :filter, class: Audits::Filter do
    allocated_to 'anyone'
    audit_status :all
  end
end
