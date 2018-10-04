FactoryBot.define do
  factory :metric, class: Facts::Metric do
    dimensions_date { Dimensions::Date.find_or_create(date.to_date) }
    dimensions_item { edition }
    pviews { 10 }
    upviews { 5 }
    transient do
      date { Time.zone.today }
      edition { create :edition }
    end
  end
end
