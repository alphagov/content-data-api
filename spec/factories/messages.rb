require 'govuk_message_queue_consumer/test_helpers/mock_message'

FactoryBot.define do
  factory :message, class: GovukMessageQueueConsumer::MockMessage do
    transient do
      sequence(:payload_version) { |i| 10 + i }
      schema_name 'detailed_guide'
      document_type 'detailed_guide'
      base_path '/base-path'
      routing_key 'news_story.major'
      attributes { {} }
    end

    trait :link_update do
      routing_key 'schema.links'
    end


    delivery_info { OpenStruct.new(routing_key: routing_key) }

    payload do
      GovukSchemas::RandomExample.for_schema(notification_schema: schema_name) do |result|
        result['base_path'] = base_path
        result['payload_version'] = payload_version
        result.merge! attributes
      end
    end

    trait :with_parts do
      schema_name 'guide'
      document_type 'guide'
      payload do
        GovukSchemas::RandomExample.for_schema(notification_schema: schema_name) do |result|
          result['base_path'] = base_path
          result['payload_version'] = payload_version
          result['details']['parts'] =
            [
              {
                "title" => "Part 1",
                "slug" => "part1",
                "body" => [
                  {
                    "content_type" => "text/govspeak",
                    "content" => "Here 1"
                  }
                ]
              },
              {
                "title" => "Part 2",
                "slug" => "part2",
                "body" => [
                  {
                    "content_type" => "text/govspeak",
                    "content" => "be 2"
                  }
                ]
              },
              {
                "title" => "Part 3",
                "slug" => "part3",
                "body" => [
                  {
                    "content_type" => "text/govspeak",
                    "content" => "some 3"
                  }
                ]
              },
              {
                "title" => "Part 4",
                "slug" => "part4",
                "body" => [
                  {
                    "content_type" => "text/govspeak",
                    "content" => "content 4."
                  }
                ]
              }
            ]
          result.merge! attributes
        end
      end
    end
  end
end
