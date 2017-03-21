FactoryGirl.define do
  factory :group do
    sequence(:slug) { |index| "slug-#{index}" }
    sequence(:name) { |index| "name-#{index}" }
    sequence(:group_type) { |index| "group-type-#{index}" }
  end
end
