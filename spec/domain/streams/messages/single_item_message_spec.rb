RSpec.describe Streams::Messages::SingleItemMessage do
  include PublishingEventProcessingSpecHelper

  subject { described_class }
  include_examples 'BaseMessage#invalid?'
  include_examples 'BaseMessage#historically_political?'
  include_examples 'BaseMessage#withdrawn_notice?'

  describe '#extract_edition_attributes' do
    let(:message) do
      msg = build(:message, attributes: message_attributes)
      msg.payload['details']['body'] = '<p>some content</p>'
      msg.payload['details']['government'] = { 'current' => true }
      msg.payload['withdrawn_notice'] = { "explanation" => 'something' }
      msg
    end
    let(:instance) { subject.new(message.payload, "routing_key") }

    it 'returns the attributes' do
      attributes = instance.extract_edition_attributes
      expect(attributes).to eq(
        expected_raw_attributes(
          content_id: message.payload['content_id'],
          document_text: 'some content',
          historical: false,
          warehouse_item_id: "#{message.payload['content_id']}:#{message.payload['locale']}",
          withdrawn: true,
        )
      )
    end
  end
end
