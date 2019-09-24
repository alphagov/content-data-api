FactoryBot.define do
  factory :publishing_api_event, class: Events::PublishingApi do
    payload { {} }
    routing_key { "routing_key" }
  end
end
