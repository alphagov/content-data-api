FactoryGirl.define do
  factory :organisation do
    sequence(:id) { |index| index }
    sequence(:slug) { |index| "slug-#{index}" }
    sequence(:title) { |index| "organisation-title-#{index}" }

    factory :organisation_with_content_items do
      transient do
        content_items_count 1
      end
      after(:create) do |organisation, evaluator|
        create_list(:content_item, evaluator.content_items_count, organisations: [organisation])
      end
    end
  end
end
