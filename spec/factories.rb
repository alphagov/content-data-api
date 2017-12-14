require_relative "./factories/link_factory"

FactoryBot.define do
  factory :content_item, class: Content::Item do
    transient do
      organisations nil
      primary_publishing_organisation nil
      parent nil
      policies nil
      policy_areas nil
      topics nil
      allocated_to nil
    end

    sequence(:content_id) { |index| "content-id-%04i" % index }
    sequence(:title) { |index| "content-item-title-%04i" % index }
    document_type { Audits::Plan.document_type_ids.sample }
    sequence(:base_path) { |index| "api/content/item/path-%04i" % index }
    public_updated_at { Time.now }
    locale { "en" }

    after(:create) do |content_item, evaluator|
      LinkFactory.add_organisations(content_item, evaluator.organisations)
      LinkFactory.add_parent(content_item, evaluator.parent)
      LinkFactory.add_primary_publishing_organisation(content_item, evaluator.primary_publishing_organisation)
      LinkFactory.add_policies(content_item, evaluator.policies)
      LinkFactory.add_policy_areas(content_item, evaluator.policy_areas)
      LinkFactory.add_topics(content_item, evaluator.topics)
      create(:allocation, content_item: content_item, user: evaluator.allocated_to) unless evaluator.allocated_to.nil?
    end

    factory :organisation do
      document_type "organisation"
    end

    factory :policy do
      document_type "policy"
    end

    factory :topic do
      document_type "topic"
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
    transient do
      organisation nil
    end

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

    before(:create) do |user, evaluator|
      unless evaluator.organisation.nil?
        user.organisation_slug = evaluator.organisation.base_path
        user.organisation_content_id = evaluator.organisation.content_id
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
    audit_status :all
    allocated_to :anyone
  end
end
