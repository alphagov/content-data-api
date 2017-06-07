FactoryGirl.define do
  factory :subtheme do
    theme
    sequence(:name) { |i| "Subtheme #{i}" }
  end
end
