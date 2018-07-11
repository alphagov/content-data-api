FactoryBot.define do
  factory :publishing_api_event do
    trait :link_update do
      routing_key 'something.links'
    end

    trait :major_update do
      routing_key 'guides.major'
    end

    sequence(:payload) { |i| "payload - #{i}" }
    sequence(:routing_key) { |i| "routing_key - #{i}" }
  end
end
