RSpec.describe PublishingAPI::EventAdapter do
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
      event = PublishingAPI::Event.new(payload: payload, routing_key: 'the-key')
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
        latest: true,
        raw_json: payload.to_json
      )
    end

    describe 'all schemas' do
      schemas = GovukSchemas::Schema.all(schema_type: "notification")
      schemas.values.each do |schema|
        payload = GovukSchemas::RandomExample.new(schema: schema).payload
        schema_name = payload.dig('schema_name')

        it "transfom schema: `#{schema_name}` with no errors" do
          event = PublishingAPI::Event.new(payload: payload, routing_key: 'the-key')

          expect { subject.to_dimension_item(event) }.to_not raise_error
        end
      end
    end
  end
end
