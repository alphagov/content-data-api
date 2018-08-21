require 'govuk_message_queue_consumer/test_helpers'

RSpec.describe PublishingAPI::Consumer do
  let(:subject) { described_class.new }

  it 'does not notify error if message is missing `locale`' do
    message = build(:message)
    message.payload.except!('locale')

    expect(GovukError).not_to receive(:notify)
    subject.process(message)
  end

  it 'grows the dimension with update events' do
    expect {
      subject.process(build(:message))
    }.to change(Dimensions::Item, :count).by(1)
  end

  it 'is idempotent' do
    message = build :message

    expect {
      subject.process(message)
      subject.process(message)
    }.to change(Dimensions::Item, :count).by(1)
  end

  it 'ignores old events' do
    message = build :message, base_path: '/base-path', attributes: { 'payload_version' => 2 }
    message2 = build :message, payload: message.payload, attributes: { 'payload_version' => 1 }

    expect {
      subject.process(message)
      subject.process(message2)
    }.to change(Dimensions::Item, :count).by(1)

    expect(Dimensions::Item.first).to have_attributes(publishing_api_payload_version: 2)
    expect(Dimensions::Item.first).to have_attributes(latest: true)
  end

  it 'deprecates old items' do
    message = build :message, base_path: '/base-path', attributes: { 'payload_version' => 2 }
    message2 = build :message, payload: message.payload.dup
    message2.payload['payload_version'] = 4
    message2.payload['title'] = 'updated-title'

    expect {
      subject.process(message)
      subject.process(message2)
    }.to change(Dimensions::Item, :count).by(2)

    expect(Dimensions::Item.find_by(publishing_api_payload_version: 2)).to have_attributes(latest: false)
    expect(Dimensions::Item.find_by(publishing_api_payload_version: 4)).to have_attributes(latest: true)
  end

  it 'does not grow the dimension if the event carry no changes in an attribute' do
    message = build :message, base_path: '/base-path', attributes: { 'payload_version' => 2 }
    message2 = build :message, payload: message.payload.dup
    message2.payload['payload_version'] = 4

    expect {
      subject.process(message)
      subject.process(message2)
    }.to change(Dimensions::Item, :count).by(1)
  end
end
