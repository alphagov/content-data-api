FactoryBot.define do
  factory :edition, class: Dimensions::Edition do
    latest { true }
    locale { 'en' }
    sequence(:content_id) { |i| "content_id - #{i}" }
    sequence(:title) { |i| "title - #{i}" }
    sequence(:base_path) { |i| "link - #{i}" }
    sequence(:description) { |i| "description - #{i}" }
    sequence(:publishing_api_payload_version)
    schema_name { 'detailed_guide' }
    document_type { 'detailed_guide' }
    warehouse_item_id { "#{content_id}:#{locale}:#{base_path}" }
    organisation_id { '17d84dc6-e5b5-4065-a8b5-8783bd934938' }
    withdrawn { false }
    historical { false }

    transient do
      date { Time.zone.today }
      replaces { nil }
      facts { {} }
    end

    to_create do |new_edition, evaluator|
      if evaluator.replaces
        new_edition.promote! evaluator.replaces
      else
        new_edition.save!
      end
      dim_date = FactoryBot.create :dimensions_date, date: evaluator.date
      FactoryBot.create :facts_edition, evaluator.facts.merge(
        dimensions_date: dim_date,
        dimensions_edition: new_edition,
        )
      new_edition
    end
  end
end
