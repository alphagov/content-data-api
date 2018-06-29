RSpec.describe PublishingAPI::MessageAdapter do
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
        content: 'some content',
        raw_json: payload
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
    let(:payload) do
      GovukSchemas::RandomExample.for_schema(notification_schema: 'guide') do |result|
        result.merge!(
          'payload_version' => 7,
          'locale' => 'fr',
          'title' => 'the-title',
          'base_path' => '/root',
          'document_type' => 'guide',
          'content_purpose_document_supertype' => 'the-supertype',
          'content_purpose_supergroup' => 'the-supergroup',
          'content_purpose_subgroup' => 'the-subgroup',
          'first_published_at' => '2018-04-19T12:00:40+01:00',
          'public_updated_at' => '2018-04-20T12:00:40+01:00',
        )

        result['details']['parts'] = [
          { 'slug' => 'part1', 'body' => [{ 'content_type' => 'text/html', 'content' => 'part 1 content' }], 'title' => 'part 1' },
          { 'slug' => 'part2', 'body' => [{ 'content_type' => 'text/html', 'content' => 'part 2 content' }], 'title' => 'part 2' }
        ]
        result
      end
    end

    it 'convert an multipart event into a set of Dimensions::Items' do
      event = build(:message, payload: payload, routing_key: 'the-key')
      result = subject.new(event).new_dimension_items

      expect(result.length).to eq(2)
    end

    it 'extracts page attributes into the Item' do
      event = build(:message, payload: payload, routing_key: 'the-key')
      dimension_item = subject.new(event).new_dimension_items[1]

      expect(dimension_item).to have_attributes(
        content_id: payload.fetch('content_id'),
        base_path: '/root/part2',
        title: 'part 2',
        content: 'part 2 content',
      )
    end

    it 'the first page of multipart pages do not have a slug in the url' do
      event = build(:message, payload: payload, routing_key: 'the-key')
      dimension_item = subject.new(event).new_dimension_items[0]

      expect(dimension_item).to have_attributes(
        content_id: payload.fetch('content_id'),
        base_path: '/root',
        title: 'part 1',
        content: 'part 1 content',
      )
    end
  end
end
