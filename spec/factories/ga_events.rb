FactoryBot.define do
  factory :ga_event, class: Events::GA do
    trait :with_views do
      pageviews { 10 }
      unique_pageviews { 5 }
      process_name { 'views' }
    end

    trait :with_user_feedback do
      is_this_useful_yes { 3 }
      is_this_useful_no { 6 }
      process_name { 'user_feedback' }
    end

    trait :with_number_of_internal_searches do
      number_of_internal_searches { 100 }
      process_name { 'number_of_internal_searches' }
    end

    sequence(:page_path) { |i| "/path/#{i}" }
    sequence(:date) { |i| i.days.ago.to_date }
  end
end
