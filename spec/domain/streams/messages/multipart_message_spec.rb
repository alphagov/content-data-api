RSpec.describe Streams::Messages::MultipartMessage do
  include PublishingEventProcessingSpecHelper

  subject { described_class }
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

  describe "#parts" do
    let(:parts) { subject.new(build(:message, :with_parts).payload).parts }

    it "returns parts for multipart content" do
      expect(parts.size).to eq(4)
    end

    it "sets the slug to basepath for first part" do
      expect(parts[0]["slug"]).to eq('/base-path')
    end
  end

  context "#title_for" do
    it "returns title for a part" do
      part = {
        "title" => "Title for part",
        "slug" => "/base-path",
        "body" =>
          [
            {
              "content_type" => "text/govspeak",
              "content" => "Summary content"
            }
          ]
        }

      message = build(:message, attributes: { 'title' => 'Main title' })
      title = subject.new(message.payload).title_for(part)

      expect(title).to eq("Main title: Title for part")
    end
  end

  context "#base_path_for_part" do
    it "returns base path without slug appended for part at index 0" do
      part_zero = {
        "title" => "Title for part",
        "slug" => "/base-path",
        "body" =>
          [
            {
              "content_type" => "text/govspeak",
              "content" => "Summary content"
            }
          ]
        }

      base_path = subject.new(build(:message, :with_parts).payload).base_path_for_part(part_zero, 0)

      expect(base_path).to eq("/base-path")
    end

    it "returns base path with slug prepended for part at index 1" do
      part_one = {
        "title" => "Part 1 title",
        "slug" => "part-1",
        "body" =>
          [
            {
              "content_type" => "text/govspeak",
              "content" => "Content 1"
            }
          ]
        }

      base_path = subject.new(build(:message, :with_parts).payload).base_path_for_part(part_one, 1)

      expect(base_path).to eq("/base-path/part-1")
    end
  end

  describe '#extract_edition_attributes' do
    let(:instance) { subject.new(message.payload) }

    context 'when the schema is a Guide' do
      let(:message) do
        message_attributes = message_attributes('document_type': 'guide')
        msg = build(:message, :with_parts, attributes: message_attributes)
        msg.payload['details']['body'] = '<p>some content</p>'
        msg
      end

      it 'return the attributes in an array' do
        attributes = instance.extract_edition_attributes
        common_attributes = expected_raw_attributes(
          content_id: message.payload['content_id'],
          raw_json: message.payload,
          schema_name: 'guide'
        ) 
        expect(attributes).to eq([
          common_attributes.merge(
            warehouse_item_id: "#{message.payload['content_id']}:#{message.payload['locale']}:/base-path",
            document_text: 'Here 1',
            title: 'the-title: Part 1',
            base_path: '/base-path'
          ),
          common_attributes.merge(
            warehouse_item_id: "#{message.payload['content_id']}:#{message.payload['locale']}:/base-path/part2",
            document_text: 'be 2',
            title: 'the-title: Part 2',
            base_path: '/base-path/part2'
          ),
          common_attributes.merge(
            warehouse_item_id: "#{message.payload['content_id']}:#{message.payload['locale']}:/base-path/part3",
            document_text: 'some 3',
            title: 'the-title: Part 3',
            base_path: '/base-path/part3'
          ),
          common_attributes.merge(
            warehouse_item_id: "#{message.payload['content_id']}:#{message.payload['locale']}:/base-path/part4",
            document_text: 'content 4.',
            title: 'the-title: Part 4',
            base_path: '/base-path/part4'
          )
        ])
      end
    end
  end

  context "Travel Advice" do
    let(:instance) { subject.new(build(:message, :travel_advice).payload) }

    it "returns base_path for first part" do
      expect(instance.parts[0]["slug"]).to eq("/base-path")
    end

    it "returns parts for travel advice with summary as first part" do
      expect(instance.parts[0]["body"][0]["content"]).to eq("summary content")
    end

    it 'returns the same items with each call' do
      expect(instance.parts.length).to eq(3)
      expect(instance.parts.length).to eq(3)
    end
  end
end
