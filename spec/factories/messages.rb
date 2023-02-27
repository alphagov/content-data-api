require "govuk_message_queue_consumer/test_helpers/mock_message"

FactoryBot.define do
  factory :message, class: GovukMessageQueueConsumer::MockMessage do
    transient do
      sequence(:payload_version) { |i| 10 + i }
      schema_name { "detailed_guide" }
      document_type { "detailed_guide" }
      base_path { "/base-path" }
      routing_key { "news_story.major" }
      attributes { {} }
      content_id { SecureRandom.uuid }
      locale { "en" }
    end

    delivery_info { OpenStruct.new(routing_key:) }

    payload do
      GovukSchemas::RandomExample.for_schema(notification_schema: schema_name) do |result|
        result["base_path"] = base_path
        result["payload_version"] = payload_version
        result["content_id"] = content_id
        result["locale"] = locale
        result.delete("withdrawn_notice")
        result.merge! attributes
      end
    end

    trait :with_parts do
      schema_name { "guide" }
      document_type { "guide" }
      payload do
        GovukSchemas::RandomExample.for_schema(notification_schema: schema_name) do |result|
          result["base_path"] = base_path
          result["payload_version"] = payload_version
          result["content_id"] = content_id
          result["locale"] = locale
          result.delete("withdrawn_notice")
          result["details"]["parts"] =
            [
              {
                "title" => "Part 1",
                "slug" => base_path,
                "body" => [
                  {
                    "content_type" => "text/govspeak",
                    "content" => "Here 1",
                  },
                  {
                    "content_type" => "text/html",
                    "content" => "Here 1",
                  },
                ],
              },
              {
                "title" => "Part 2",
                "slug" => "part2",
                "body" => [
                  {
                    "content_type" => "text/govspeak",
                    "content" => "be 2",
                  },
                  {
                    "content_type" => "text/html",
                    "content" => "be 2",
                  },
                ],
              },
              {
                "title" => "Part 3",
                "slug" => "part3",
                "body" => [
                  {
                    "content_type" => "text/govspeak",
                    "content" => "some 3",
                  },
                  {
                    "content_type" => "text/html",
                    "content" => "some 3",
                  },
                ],
              },
              {
                "title" => "Part 4",
                "slug" => "part4",
                "body" => [
                  {
                    "content_type" => "text/govspeak",
                    "content" => "content 4.",
                  },
                  {
                    "content_type" => "text/html",
                    "content" => "content 4.",
                  },
                ],
              },
            ]
          result.merge! attributes
        end
      end
    end

    trait :guide do
      with_parts
    end

    trait :travel_advice do
      schema_name { "travel_advice" }
      document_type { "travel_advice" }
      transient do
        summary { "summary content" }
      end
      payload do
        GovukSchemas::RandomExample.for_schema(notification_schema: schema_name) do |result|
          result["base_path"] = base_path
          result["payload_version"] = payload_version
          result["content_id"] = content_id
          result["locale"] = locale
          result.delete("withdrawn_notice")
          result["details"]["summary"] = [
            "content_type" => "text/html",
            "content" => summary,
          ]
          result["details"]["parts"] =
            [
              {
                "title" => "Part 1",
                "slug" => "part1",
                "body" => [
                  {
                    "content_type" => "text/html",
                    "content" => "Here 1",
                  },
                ],
              },
              {
                "title" => "Part 2",
                "slug" => "part2",
                "body" => [
                  {
                    "content_type" => "text/html",
                    "content" => "be 2",
                  },
                ],
              },
            ]
          result.merge! attributes
        end
      end
    end
  end

  factory :gone_message, parent: :message do
    payload do
      {
        "document_type" => "gone",
        "schema_name" => "gone",
        "base_path" => base_path,
        "locale" => locale,
        "publishing_app" => "whitehall",
        "details" => {
          "explanation" => "",
          "alternative_path" => "",
        },
        "routes" => [
          {
            "path" => content_id,
            "type" => "exact",
          },
        ],
        "content_id" => content_id,
        "payload_version" => payload_version,
      }
    end
  end

  factory :redirect_message, parent: :message do
    payload do
      {
        "document_type" => "redirect",
        "schema_name" => "redirect",
        "base_path" => base_path,
        "locale" => locale,
        "publishing_app" => "whitehall",
        "details" => {
          "explanation" => "",
          "alternative_path" => "",
        },
        "routes" => [
          {
            "path" => content_id,
            "type" => "exact",
          },
        ],
        "content_id" => content_id,
        "payload_version" => payload_version,
      }
    end
  end
end
