RSpec.describe PublishingAPI::MessageAdapter do
  subject { described_class }

  describe '.to_dimension_item' do
    it 'convert an Event into a Dimensions::Item' do
      payload = GovukSchemas::RandomExample.for_schema(notification_schema: "detailed_guide") do |result|
        result.merge(
          'payload_version' => 7,
          'locale' => 'fr',
          'title' => 'the-title',
          'document_type' => 'detailed_guide',
          'content_purpose_document_supertype' => 'the-supertype',
          'content_purpose_supergroup' => 'the-supergroup',
          'content_purpose_subgroup' => 'the-subgroup',
          'first_published_at' => '2018-04-19T12:00:40+01:00',
          'public_updated_at' => '2018-04-20T12:00:40+01:00',
        )
      end

      event = build(:message, payload: payload, routing_key: 'the-key')
      dimension_item = subject.to_dimension_item(event)

      expect(dimension_item).to have_attributes(
        content_id: payload.fetch('content_id'),
        base_path: payload.fetch('base_path'),
        publishing_api_payload_version: 7,
        locale: 'fr',
        title: 'the-title',
        document_type: 'detailed_guide',
        content_purpose_document_supertype: 'the-supertype',
        content_purpose_supergroup: 'the-supergroup',
        content_purpose_subgroup: 'the-subgroup',
        first_published_at: Time.zone.parse('2018-04-19T12:00:40+01:00'),
        public_updated_at: Time.zone.parse('2018-04-20T12:00:40+01:00'),
        schema_name: 'detailed_guide',
        latest: true,
        raw_json: payload
      )
    end

    it 'converts the primary organisation' do
      payload = GovukSchemas::RandomExample.for_schema(notification_schema: "detailed_guide") do |result|
        result['expanded_links']['primary_publishing_organisation'] = [
          {
            'content_id' => 'ce91c056-8165-49fe-b318-b71113ab4a30',
            'title' => 'the-title',
            'withdrawn' => 'false',
            'locale' => 'en',
            'base_path' => '/the-base-path'
          }
        ]

        result
      end

      event = build(:message, payload: payload, routing_key: 'the-key')
      dimension_item = subject.to_dimension_item(event)

      expect(dimension_item).to have_attributes(
        primary_organisation_content_id: 'ce91c056-8165-49fe-b318-b71113ab4a30',
        primary_organisation_title: 'the-title',
        primary_organisation_withdrawn: false,
      )
    end

    describe 'all schemas' do
      schemas = GovukSchemas::Schema.all(schema_type: "notification")
      schemas.each_value do |schema|
        payload = GovukSchemas::RandomExample.new(schema: schema).payload
        schema_name = payload.dig('schema_name')

        it "transfom schema: `#{schema_name}` with no errors" do
          event = build(:message, payload: payload, routing_key: 'the-key')

          expect { subject.to_dimension_item(event) }.to_not raise_error
        end
      end
    end
  end
end
