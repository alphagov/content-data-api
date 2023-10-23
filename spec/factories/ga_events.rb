FactoryBot.define do
  factory :ga_event, class: Events::GA do
    trait :with_views do
      pviews { 10 }
      upviews { 5 }
      process_name { "views" }
    end

    trait :with_entrances do
      entrances { 10 }
    end

    trait :with_exits do
      entrances { 10 }
    end

    trait :with_bounces do
      entrances { 10 }
    end

    trait :with_pagetime do
      entrances { 29 }
    end

    trait :with_user_feedback do
      useful_yes { 3 }
      useful_no { 6 }
      process_name { "user_feedback" }
    end

    trait :with_searches do
      searches { 100 }
      process_name { "searches" }
    end

    sequence(:page_path) { |i| "/path/#{i}" }
    sequence(:date) { |i| i.days.ago.to_date }
  end
end
