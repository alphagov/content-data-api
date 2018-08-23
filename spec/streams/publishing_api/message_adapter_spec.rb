RSpec.describe PublishingAPI::MessageAdapter do
  skip  do
    'work out where to put these'
  end
  subject { described_class }

  describe '.new_dimension_items' do
    it 'convert an Event into a Dimensions::Item' do
      payload = GovukSchemas::RandomExample.for_schema(notification_schema: 'detailed_guide') do |result|
        result.merge!(
          'payload_version' => 7,
          'locale' => 'fr',
          'title' => 'the-title',
          'document_type' => 'detailed_guide',
          'content_purpose_document_supertype' => 'the-supertype',
          'content_purpose_supergroup' => 'the-supergroup',
          'content_purpose_subgroup' => 'the-subgroup',
          'first_published_at' => '2018-04-19T12:00:40+01:00',
          'public_updated_at' => '2018-04-20T12:00:40+01:00',
          'phase' => 'live',
          'publishing_app' => 'calendars',
          'rendering_app' => 'calendars',
          'analytics_identifier' => 'analytics_identifier',
          'update_type' => 'major',
          'expanded_links' => { 'policy_areas' => [] },
        )
        result['details']['body'] = 'some content'
        result
      end

      event = build(:message, payload: payload, routing_key: 'the-key')
      dimension_item = subject.new(event).new_dimension_items[0]

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
        document_text: 'some content',
        phase: 'live',
        publishing_app: 'calendars',
        rendering_app: 'calendars',
        analytics_identifier: 'analytics_identifier',
        update_type: 'major',
        raw_json: payload,
      )
    end

    it 'converts the primary organisation' do
      payload = GovukSchemas::RandomExample.for_schema(notification_schema: 'detailed_guide') do |result|
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
      dimension_item = subject.new(event).new_dimension_items[0]

      expect(dimension_item).to have_attributes(
        primary_organisation_content_id: 'ce91c056-8165-49fe-b318-b71113ab4a30',
        primary_organisation_title: 'the-title',
        primary_organisation_withdrawn: false,
      )
    end

    describe 'all schemas' do
      schemas = GovukSchemas::Schema.all(schema_type: 'notification')
      schemas.each_value do |schema|
        payload = GovukSchemas::RandomExample.new(schema: schema).payload
        schema_name = payload.dig('schema_name')

        it "transfom schema: `#{schema_name}` with no errors" do
          event = build(:message, payload: payload, routing_key: 'the-key')

          expect { subject.new(event).new_dimension_items }.to_not raise_error
        end
      end
    end
  end

  describe '.new_dimension_items' do


    context 'item is a travel guide' do
      it 'uses summary as first part without base_path containing the slug' do
        travel_advice_message = build(:message, :travel_advice)
        dimension_item = subject.new(travel_advice_message).new_dimension_items[0]

        expect(dimension_item).to have_attributes(
          base_path: '/base-path',
          title: 'Summary',
          document_text: 'summary content',
        )
      end

      it 'uses `parts` as the additional pages with base_path containing the slug' do
        travel_advice_message = build(:message, :travel_advice)
        dimension_item = subject.new(travel_advice_message).new_dimension_items[1]

        expect(dimension_item).to have_attributes(
          base_path: '/base-path/part1',
          title: 'Part 1',
          document_text: 'Here 1',
        )
      end
    end
  end
end
