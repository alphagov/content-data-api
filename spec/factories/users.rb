FactoryGirl.define do
  factory :user do
    sequence(:uid) { |i| "user-#{i}" }
    name 'Test User'
    email 'user@example.com'
    permissions { ['signin'] }
    organisation_slug "government-digital-service"
  end
end
