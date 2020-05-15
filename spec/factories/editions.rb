FactoryBot.define do
  factory :edition, class: Dimensions::Edition do
    live { true }
    locale { "en" }
    parent { nil }
    sequence(:content_id) { SecureRandom.uuid }
    sequence(:title) { |i| "title - #{i}" }
    sequence(:base_path) { |i| "/base-path-#{i}" }
    sequence(:description) { |i| "description - #{i}" }
    sequence(:publishing_api_payload_version)
    schema_name { "detailed_guide" }
    document_type { "detailed_guide" }
    warehouse_item_id { "#{content_id}:#{locale}" }
    primary_organisation_id { "17d84dc6-e5b5-4065-a8b5-8783bd934938" }
    organisation_ids { [] }
    withdrawn { false }
    historical { false }
    association :publishing_api_event
    sibling_order { nil }

    transient do
      date { Time.zone.today }
      replaces { nil }
      facts { {} }
    end

    to_create do |new_edition, evaluator|
      if evaluator.replaces
        new_edition.content_id = evaluator.replaces.content_id
        new_edition.locale = evaluator.replaces.locale
        new_edition.warehouse_item_id = evaluator.replaces.warehouse_item_id
        new_edition.promote! evaluator.replaces
      else
        new_edition.save!
      end
      dim_date = FactoryBot.create :dimensions_date, date: evaluator.date
      FactoryBot.create :facts_edition,
                        evaluator.facts.merge(
                          dimensions_date: dim_date,
                          dimensions_edition: new_edition,
                        )
      new_edition
    end

    trait :multipart do
      warehouse_item_id { "#{content_id}:#{locale}:#{base_path}" }
    end
  end
end
