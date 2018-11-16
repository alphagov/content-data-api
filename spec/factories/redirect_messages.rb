require 'govuk_message_queue_consumer/test_helpers/mock_message'

FactoryBot.define do
  factory :redirect_message, class: GovukMessageQueueConsumer::MockMessage do
    transient do
      base_path { '/base-path' }
      content_id { SecureRandom.uuid }
      destination { '/new/base-path' }
      payload_version { generate :payload }
    end

    delivery_info { OpenStruct.new(routing_key: 'redirect.links') }

    payload do
      GovukSchemas::RandomExample.for_schema(notification_schema: 'redirect') do |result|
        result['base_path'] = base_path
        result['content_id'] = content_id
        result['payload_version'] = payload_version
        result['document_type'] = 'redirect'
        result['update_type'] = 'republish'
        result['schema_name'] = 'redirect'
        result['publishing_app'] = 'whitehall'
        result['redirects'] ||= [{}]
        result['redirects'][0]['path'] = '/new/base-path'
        result['redirects'][0]['type'] = 'exact'
        result['redirects'][0]['destination'] = destination
        result.except!('locale')
        result
      end
    end
  end
end
