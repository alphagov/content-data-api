require 'govuk_message_queue_consumer/test_helpers'

RSpec.describe PublishingAPI::Consumer do
  include PublishingEventProcessingSpecHelper
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

  it 'does not grow the dimension if the event carries no changes in an attribute' do
    message = build :message, base_path: '/base-path', attributes: { 'payload_version' => 2 }
    message2 = build :message, payload: message.payload.dup
    message2.payload['payload_version'] = 4

    expect {
      subject.process(message)
      subject.process(message2)
    }.to change(Dimensions::Item, :count).by(1)
  end

  it 'grows the dimension if the event carries a change in the body' do
    message = build :message, base_path: '/base-path', attributes: { 'payload_version' => 2 }
    message2 = build :message, payload: message.payload.deep_dup
    message2.payload['payload_version'] = 4
    message2.payload['details']['body'] = '<p>different content</p>'
    expect {
      subject.process(message)
      subject.process(message2)
    }.to change(Dimensions::Item, :count).by(2)
  end

  it 'updates the attributes correctly' do
    message = build :message, base_path: '/base-path', attributes: message_attributes
    message.payload['details']['body'] = '<p>some content</p>'
    subject.process(message)
    latest_item = Dimensions::Item.where(base_path: '/base-path', latest: true).first
    expect(latest_item).to have_attributes(expected_attributes(content_id: message.payload['content_id']))
  end

  describe 'all schemas' do
    before do
      allow(GovukError).to receive(:notify)
    end

    schemas = GovukSchemas::Schema.all(schema_type: 'notification')
    schemas.each_value do |schema|
      payload = GovukSchemas::RandomExample.new(schema: schema).payload
      schema_name = payload.dig('schema_name')
      unless %w{travel_advice guide placeholder}.include?(schema_name)

        %w{major minor links republish unpublish}.each do |update_type|
          it "handles event for: `#{schema_name}` with no errors for a `#{update_type}` update" do
            message = build(:message, payload: payload, routing_key: "#{schema_name}.#{update_type}")

            subject.process(message)

            expect(GovukError).not_to have_received(:notify)
          end
        end
      end
    end
  end
end
