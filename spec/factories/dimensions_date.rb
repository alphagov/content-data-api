FactoryBot.define do
  factory :dimensions_date, class: Dimensions::Date do
    sequence(:date) { |i| i.days.ago.to_date }

    initialize_with { Dimensions::Date.build(date) }
  end
end
