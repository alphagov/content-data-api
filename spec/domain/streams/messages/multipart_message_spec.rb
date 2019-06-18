RSpec.describe Streams::Messages::MultipartMessage do
  include PublishingEventProcessingSpecHelper

  subject { described_class }

  include_examples 'BaseMessage#invalid?'
  include_examples 'BaseMessage#organisation_ids'
  include_examples 'BaseMessage#historically_political?'
  include_examples 'BaseMessage#withdrawn_notice?'

  describe ".is_multipart?" do
    it "returns true if message is for multipart item" do
      expect(subject.is_multipart?(build(:message, :with_parts).payload)).to be(true)
    end

    it "returns false if message is for single part item" do
      expect(subject.is_multipart?(build(:message).payload)).to be(false)
    end
  end

  describe '#edition_attributes' do
    let(:instance) { subject.new(message.payload, "routing_key") }

    context 'when the schema is a Guide' do
      let(:message) do
        message_attributes = message_attributes('document_type': 'guide')
        msg = build(:message, :with_parts, attributes: message_attributes)
        msg.payload['details']['body'] = '<p>some content</p>'
        msg
      end

      it 'return the attributes in an array' do
        attributes = instance.edition_attributes
        common_attributes = expected_raw_attributes(
          content_id: message.payload['content_id'],
          schema_name: 'guide'
        )
        expect(attributes).to eq([
          common_attributes.merge(
            warehouse_item_id: "#{message.payload['content_id']}:#{message.payload['locale']}",
            document_text: 'Here 1',
            sibling_order: 0,
            title: 'the-title: Part 1',
            base_path: '/base-path'
          ),
          common_attributes.merge(
            warehouse_item_id: "#{message.payload['content_id']}:#{message.payload['locale']}:part2",
            document_text: 'be 2',
            title: 'the-title: Part 2',
            sibling_order: 1,
            base_path: '/base-path/part2'
          ),
          common_attributes.merge(
            warehouse_item_id: "#{message.payload['content_id']}:#{message.payload['locale']}:part3",
            document_text: 'some 3',
            title: 'the-title: Part 3',
            sibling_order: 2,
            base_path: '/base-path/part3'
          ),
          common_attributes.merge(
            warehouse_item_id: "#{message.payload['content_id']}:#{message.payload['locale']}:part4",
            document_text: 'content 4.',
            title: 'the-title: Part 4',
            sibling_order: 3,
            base_path: '/base-path/part4'
          )
        ])
      end
    end

    context 'when the schema is a Travel Advice' do
      let(:message) do
        override_attributes = message_attributes.reject { |k, _| k == 'document_type' }
        msg = build(:message, :travel_advice, attributes: override_attributes)
        msg.payload['details']['body'] = '<p>some content</p>'
        msg
      end

      it 'return the attributes in an array' do
        attributes = instance.edition_attributes
        common_attributes = expected_raw_attributes(
          content_id: message.payload['content_id'],
          schema_name: 'travel_advice',
          document_type: 'travel_advice'
        )
        expect(attributes).to eq([
          common_attributes.merge(
            warehouse_item_id: "#{message.payload['content_id']}:#{message.payload['locale']}",
            document_text: 'summary content',
            title: 'the-title: Summary',
            sibling_order: 0,
            base_path: '/base-path'
          ),
          common_attributes.merge(
            warehouse_item_id: "#{message.payload['content_id']}:#{message.payload['locale']}:part1",
            document_text: 'Here 1',
            title: 'the-title: Part 1',
            sibling_order: 1,
            base_path: '/base-path/part1'
          ),
          common_attributes.merge(
            warehouse_item_id: "#{message.payload['content_id']}:#{message.payload['locale']}:part2",
            document_text: 'be 2',
            title: 'the-title: Part 2',
            sibling_order: 2,
            base_path: '/base-path/part2'
          )
        ])
      end
    end
  end
end
