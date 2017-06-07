FactoryGirl.define do
  factory :theme do
    sequence(:name) { |i| "Theme #{i}" }
  end
end
