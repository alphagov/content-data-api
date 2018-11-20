RSpec.describe Streams::Messages::RedirectMessage do
  include PublishingEventProcessingSpecHelper

  subject { described_class }

  let(:payload) { build(:redirect_message).payload }
  let(:message) { described_class.new(payload) }

  describe '#redirect?' do
    context 'when payload has redirect as schema type and no locale' do
      it 'returns true' do
        expect(subject.is_redirect?(payload.except('locale'))).to eq(true)
      end
    end
  end

  describe '#extract_edition_attributes' do
    let(:instance) { subject.new(message.payload) }

    it 'returns the attributes' do
      attributes = instance.extract_edition_attributes

      expect(attributes).to include(
        document_type: 'redirect',
        content_id: message.payload['content_id'],
        warehouse_item_id: nil,
        raw_json: message.payload
      )
    end
  end
end
