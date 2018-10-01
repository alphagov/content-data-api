FactoryBot.define do
  factory :metric, class: Facts::Metric do
    dimensions_date { Dimensions::Date.find_or_create(date.to_date) }
    dimensions_item { edition }
    pageviews { 10 }
    unique_pageviews { 5 }
    transient do
      date { Time.zone.today }
      edition { create :dimensions_item }
    end
  end
end
