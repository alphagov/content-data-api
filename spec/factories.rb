FactoryGirl.define do
  factory :organisation do
    sequence(:id) { |n| n }
    sequence(:slug) { |n| "organisation-slug-#{n}" }
    sequence(:content_id) { |n| "fdur5845-fu54-fd86-gy75-5fjdkjfjkfe3-#{n}" }
    number_of_pages 3
  end

  factory :content_item do
    sequence(:id) { |n| n }
    sequence(:content_id) { |n| "fdur5845-fu54-fd86-gy75-5fjdkjfjkfe3-#{n}" }
  end
end
