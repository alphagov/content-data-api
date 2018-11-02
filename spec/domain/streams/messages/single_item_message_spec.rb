RSpec.describe Streams::Messages::SingleItemMessage do
  include PublishingEventProcessingSpecHelper

  subject { described_class }
  include_examples 'BaseMessage#historically_political?'
  include_examples 'BaseMessage#withdrawn_notice?'

  describe '#extract_edition_attributes' do
    let(:message) do
      msg = build(:message, attributes: message_attributes)
      msg.payload['details']['body'] = '<p>some content</p>'
      msg.payload['details']['government'] = { 'current' => true }
      msg.payload['withdrawn_notice'] = { explanation: 'something' }
      msg
    end
    let(:instance) { subject.new(message.payload) }

    it 'return the attributes as the single item in an array' do
      attributes = instance.extract_edition_attributes
      expect(attributes.length).to eq(1)
      expect(attributes.first).to eq(
        expected_attributes(
          content_id: message.payload['content_id'],
          base_path: '/base-path',
          title: 'the-title',
          document_text: 'some content',
          historical: false,
          withdrawn: true,
          primary_organisation_withdrawn: "false",
          public_updated_at: "2018-04-20T12:00:40+01:00",
          first_published_at: "2018-04-19T12:00:40+01:00",
          raw_json: message.payload
        )
      )
    end
  end
end
