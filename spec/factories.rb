FactoryBot.define do
  factory :user do
    transient do
      organisation nil
    end

    sequence(:uid) { |i| "user-#{i}" }
    sequence(:name) { |i| "Test User #{i}" }
    email 'user@example.com'
    permissions { ['signin'] }
    organisation_slug "government-digital-service"
  end

  factory :dimensions_date, class: Dimensions::Date do
    sequence(:date) { |i| i.days.ago.to_date }

    initialize_with { Dimensions::Date.build(date) }
  end

  factory :dimensions_item, class: Dimensions::Item do
    latest true
    sequence(:content_id) { |i| "content_id - #{i}" }
    sequence(:title) { |i| "title - #{i}" }
    sequence(:base_path) { |i| "link - #{i}" }
    sequence(:description) { |i| "description - #{i}" }
    sequence(:raw_json) { |i| "json - #{i}" }
    number_of_pdfs 0

    factory :outdated_item do
      outdated true
      outdated_at { 2.days.ago }
    end
  end

  factory :metric, class: Facts::Metric do
    dimensions_date
    dimensions_item
    pageviews 10
    unique_pageviews 5
  end

  factory :ga, class: Events::GA do
    sequence(:page_path) { |i| "/path/#{i}" }
    sequence(:date) { |i| i.days.ago.to_date }
    pageviews 10
    unique_pageviews 5
  end
end
