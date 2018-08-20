FactoryBot.define do
  factory :metric, class: Facts::Metric do
    dimensions_date
    dimensions_item
    pageviews { 10 }
    unique_pageviews { 5 }
  end
end
