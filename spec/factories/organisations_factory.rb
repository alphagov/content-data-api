FactoryGirl.define do
  factory :organisation do
    sequence(:slug) { |index| "slug-#{index}" }

    factory :organisation_with_content_items do
      transient do
        content_items_count 1
      end
      after(:create) do |organisation, evaluator|
        create_list(:content_item, evaluator.content_items_count, organisation: organisation)
      end
    end
  end
end
