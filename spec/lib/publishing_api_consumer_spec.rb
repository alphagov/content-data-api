require 'rails_helper'
require 'publishing_api_consumer'
require 'govuk_message_queue_consumer/test_helpers'

RSpec.describe PublishingApiConsumer do
  let(:subject) { described_class.new }

  it_behaves_like 'a message queue processor'

  context 'when the Dimensions::Item already exists' do
    let(:latest_item) { create(:dimensions_item, latest: true, dirty: false) }

    let(:older_item) do
      create(:dimensions_item,
        content_id: latest_item.content_id,
        base_path: latest_item.base_path,
        latest: false,
        dirty: false)
    end
    let(:different_item) { create(:dimensions_item, latest: true, dirty: false) }
    let(:base_path) { '/some/path/to' }
    let(:payload) do
      {
        'base_path' => latest_item.base_path,
        'content_id' => latest_item.content_id
      }
    end
    let(:message) { double('message', payload: payload) }

    before :each do
      allow(message).to receive(:ack)
      subject.process(message)
    end

    it 'updates the latest content item with a dirty flag' do
      expect(latest_item.reload.dirty?).to be true
      expect(older_item.reload.dirty?).to be false
      expect(different_item.reload.dirty?).to be false
    end

    it "ack's the message" do
      expect(message).to have_received(:ack)
    end
  end

  context 'when the Dimensions::Item does not exist yet' do
    let(:payload) do
      {
        'base_path' => '/path/to/new/content',
        'content_id' => 'does-not-exist-yet',
      }
    end
    let(:message) { double('message', payload: payload) }

    before :each do
      allow(message).to receive(:ack)
      subject.process(message)
    end

    it 'creates a new item with the correct base path' do
      item = Dimensions::Item.where(content_id: payload['content_id']).first

      expect(item).to have_attributes(
        base_path: payload['base_path'],
        latest: true,
        dirty: true,
      )
    end

    it "ack's the message" do
      expect(message).to have_received(:ack)
    end
  end
end
