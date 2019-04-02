require 'govuk_message_queue_consumer/test_helpers'

RSpec.describe Streams::Consumer do
  include PublishingEventProcessingSpecHelper

  let(:subject) { described_class.new }

  it 'grows the dimension with update events' do
    expect {
      subject.process(build(:message))
    }.to change(Dimensions::Edition, :count).by(1)
  end

  it 'grows the publishing api events with message' do
    expect {
      subject.process(build(:message))
    }.to change(Events::PublishingApi, :count).by(1)
  end

  it 'is idempotent' do
    message = build :message

    expect {
      subject.process(message)
      subject.process(message)
    }.to change(Dimensions::Edition, :count).by(1)
  end

  it 'ignores old events' do
    message = build :message, base_path: '/base-path', attributes: { 'payload_version' => 2 }
    message2 = build :message, payload: message.payload, attributes: { 'payload_version' => 1 }

    expect {
      subject.process(message)
      subject.process(message2)
    }.to change(Dimensions::Edition, :count).by(1)
    expect(Dimensions::Edition.first).to have_attributes(
      publishing_api_payload_version: 2,
      live: true
    )
  end

  it 'does not grow the dimension if the event carries no changes in an attribute' do
    message = build :message, base_path: '/base-path', attributes: { 'payload_version' => 2 }
    message2 = build :message, payload: message.payload.dup
    message2.payload['payload_version'] = 4

    expect {
      subject.process(message)
      subject.process(message2)
    }.to change(Dimensions::Edition, :count).by(1)
  end

  context 'when the event carries a change' do
    it 'deprecates old editions' do
      message = build :message, base_path: '/base-path', attributes: { 'payload_version' => 2 }
      message2 = build :message, payload: message.payload.dup
      message2.payload['payload_version'] = 4
      message2.payload['title'] = 'updated-title'

      expect {
        subject.process(message)
        subject.process(message2)
      }.to change(Dimensions::Edition, :count).by(2)

      expect(Dimensions::Edition.find_by(publishing_api_payload_version: 2)).to have_attributes(live: false)
      expect(Dimensions::Edition.find_by(publishing_api_payload_version: 4)).to have_attributes(live: true)
    end

    it 'grows the dimension' do
      message = build :message, base_path: '/base-path', attributes: { 'payload_version' => 2 }
      message2 = build :message, payload: message.payload.deep_dup
      message2.payload['payload_version'] = 4
      message2.payload['details']['body'] = '<p>different content</p>'
      expect {
        subject.process(message)
        subject.process(message2)
      }.to change(Dimensions::Edition, :count).by(2)
    end

    it 'updates the attributes correctly' do
      message = build :message, base_path: '/base-path', attributes: message_attributes
      message.payload['details']['body'] = '<p>some content</p>'
      subject.process(message)
      live_edition = Dimensions::Edition.live.find_by(base_path: '/base-path')
      expect(live_edition).to have_attributes(expected_edition_attributes(content_id: message.payload['content_id']))
    end

    it 'assigns the same warehouse_item_id to the new edition' do
      content_id = SecureRandom.uuid

      message = build :message, base_path: '/base-path', content_id: content_id, attributes: { 'payload_version' => 2 }
      subject.process(message)

      message2 = build :message, content_id: content_id, payload: message.payload.deep_dup
      message2.payload['payload_version'] = 4
      message2.payload['details']['body'] = '<p>different content</p>'
      subject.process(message2)

      warehouse_ids = Dimensions::Edition.where(base_path: '/base-path').pluck(:warehouse_item_id)
      expect(warehouse_ids.uniq).to eq(["#{content_id}:en"])
    end
  end

  context 'when the base path has changed' do
    let(:content_id) { SecureRandom.uuid }
    let(:warehouse_item_id) { "#{content_id}:en" }
    let(:new_base_path) { '/new/base/path' }

    it 'creates the new edition with the warehouse_item_id of the old edition' do
      create :edition,
             base_path: '/old/base/path',
             content_id: content_id,
             warehouse_item_id: warehouse_item_id,
             publishing_api_payload_version: 2
      message = build :message, base_path: new_base_path, content_id: content_id, payload_version: 3

      subject.process(message)

      new_edition = Dimensions::Edition.live.find_by(content_id: content_id)
      expect(new_edition).to have_attributes(warehouse_item_id: warehouse_item_id, base_path: new_base_path)
    end
  end

  context 'when the message is for an organisation' do
    it 'assigns the acronym' do
      message = build :message, base_path: '/base-path', attributes: message_attributes
      message.payload['details']['acronym'] = 'HMRC'
      subject.process(message)

      live_edition = Dimensions::Edition.live.find_by(base_path: '/base-path')
      expect(live_edition).to have_attributes(acronym: 'HMRC')
    end
  end

  context 'when handling unpublishing related messages' do
    it 'it does not grow dimensions_editions unnecessarily' do
      edition = create :edition
      base_payload_version = edition.publishing_api_payload_version

      first_gone_message = build(
        :gone_message,
        edition.slice(:base_path, :locale, :content_id)
      )
      first_gone_message.payload['payload_version'] = base_payload_version + 1

      second_gone_message = build :message, payload: first_gone_message.payload.dup
      second_gone_message.payload['payload_version'] = base_payload_version + 2
      expect {
        subject.process(first_gone_message)
      }.to change(Dimensions::Edition, :count).by(1)
      expect {
        subject.process(second_gone_message)
      }.to change(Dimensions::Edition, :count).by(0)
    end
  end
end
