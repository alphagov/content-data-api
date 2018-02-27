require_relative "./factories/link_factory"

FactoryBot.define do
  factory :content_item, class: Item do
    transient do
      organisations nil
      primary_publishing_organisation nil
      parent nil
      policies nil
      policy_areas nil
      topics nil
    end

    sequence(:content_id) { |index| "content-id-%04i" % index }
    sequence(:title) { |index| "content-item-title-%04i" % index }
    document_type { :answer }
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

  factory :link, class: Link do
    sequence(:source_content_id) { |i| "source-#{i}" }
    sequence(:target_content_id) { |i| "target-#{i}" }
    link_type "organisations"
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

    before(:create) do |user, evaluator|
      unless evaluator.organisation.nil?
        user.organisation_slug = evaluator.organisation.base_path
        user.organisation_content_id = evaluator.organisation.content_id
      end
    end
  end

  factory :dimensions_date, class: Dimensions::Date do
    sequence(:date) { |i| i.days.ago.to_date }

    initialize_with { Dimensions::Date.build(date) }
  end

  factory :dimensions_organisation, class: Dimensions::Organisation do
    sequence(:title) { |i| "title - #{i}" }
    sequence(:slug) { |i| "slug - #{i}" }
    sequence(:description) { |i| "description - #{i}" }
    sequence(:link) { |i| "link - #{i}" }
    sequence(:organisation_id) { |i| "organisation_id - #{i}" }
    sequence(:state) { |i| "state - #{i}" }
    sequence(:content_id) { |i| "content_id - #{i}" }
  end

  factory :dimensions_item, class: Dimensions::Item do
    latest true
    sequence(:content_id) { |i| "content_id - #{i}" }
    sequence(:title) { |i| "title - #{i}" }
    sequence(:base_path) { |i| "link - #{i}" }
    sequence(:description) { |i| "description - #{i}" }
    sequence(:raw_json) { |i| "json - #{i}" }
    number_of_pdfs 0
  end

  factory :metric, class: Facts::Metric do
    dimensions_date
    dimensions_item
    pageviews 10
    unique_pageviews 5
  end
end
