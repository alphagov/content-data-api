require 'rails_helper'
require 'publishing_api_consumer'
require 'govuk_message_queue_consumer/test_helpers'

RSpec.describe PublishingApiConsumer do
  let(:subject) { described_class.new }

  it_behaves_like 'a message queue processor'

  context 'when the Dimensions::Item already exists - all events but unpublish' do
    let!(:latest_item_en) { create(:dimensions_item, latest: true, outdated: false, locale: 'en') }
    let!(:latest_item_de) { create(:dimensions_item, latest: true, outdated: false, locale: 'de') }

    let!(:older_item) do
      create(:dimensions_item,
        content_id: latest_item_en.content_id,
        base_path: latest_item_en.base_path,
        latest: false,
        outdated: false)
    end
    let!(:different_item) { create(:dimensions_item, latest: true, outdated: false) }
    let!(:base_path) { '/some/path/to' }
    let!(:payload) do
      {
        'base_path' => latest_item_de.base_path,
        'content_id' => latest_item_de.content_id,
        'locale' => 'de'
      }
    end
    let!(:message) do
      double('message',
        payload: payload,
        delivery_info: double('del_info', routing_key: 'news_story.major'))
    end

    before :each do
      allow(message).to receive(:ack)
      subject.process(message)
    end

    it 'updates the latest content of the correct locale with an outdated flag' do
      expect(latest_item_de.reload.outdated?).to be true
      expect(latest_item_en.reload.outdated?).to be false
      expect(older_item.reload.outdated?).to be false
      expect(different_item.reload.outdated?).to be false
    end

    it 'leaves the status as "live"' do
      expect(latest_item_en.reload.status).to eq('live')
    end

    it "ack's the message" do
      expect(message).to have_received(:ack)
    end
  end

  context 'on an unpublish event' do
    let!(:latest_item_en) { create(:dimensions_item, latest: true, outdated: false, locale: 'en') }
    let!(:latest_item_fr) { create(:dimensions_item, latest: true, outdated: false, locale: 'fr') }
    let!(:payload) do
      {
        'base_path' => latest_item_en.base_path,
        'content_id' => latest_item_en.content_id,
        'locale' => 'en'
      }
    end
    let!(:message) do
      double('message',
        payload: payload,
        delivery_info: double('del_info', routing_key: 'gone.unpublished'))
    end

    before :each do
      allow(message).to receive(:ack)
      subject.process(message)
    end

    it 'updates the latest content item with a outdated flag' do
      expect(latest_item_en.reload.outdated?).to be true
      expect(latest_item_fr.reload.outdated?).to be false
    end

    it 'sets the status to "gone"' do
      expect(latest_item_en.reload.status).to eq('gone')
      expect(latest_item_fr.reload.status).to eq('live')
    end

    it "ack's the message" do
      expect(message).to have_received(:ack)
    end
  end

  context 'when the Dimensions::Item does not exist yet' do
    let!(:payload) do
      {
        'base_path' => '/path/to/new/content',
        'content_id' => 'does-not-exist-yet',
        'locale' => 'en',
      }
    end
    let!(:message) { double('message', payload: payload) }

    before :each do
      allow(message).to receive(:ack)
      subject.process(message)
    end

    it 'creates a new item with the correct base path' do
      item = Dimensions::Item.where(content_id: payload['content_id']).first

      expect(item).to have_attributes(
        base_path: payload['base_path'],
        latest: true,
        outdated: true,
      )
    end

    it "ack's the message" do
      expect(message).to have_received(:ack)
    end
  end
end
