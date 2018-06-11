require 'govuk_message_queue_consumer/test_helpers'

RSpec.describe PublishingAPI::Consumer do
  let(:subject) { described_class.new }

  before do
    response = {
      readability: { 'count' => 1 },
      contractions: { 'count' => 2 },
      equality: { 'count' => 3 },
      indefinite_article: { 'count' => 4 },
      passive: { 'count' => 5 },
      profanities: { 'count' => 6 },
      redundant_acronyms: { 'count' => 7 },
      repeated_words: { 'count' => 8 },
      simplify: { 'count' => 9 },
      spell: { 'count' => 10 }
    }
    stub_request(:post, 'https://govuk-content-quality-metrics.cloudapps.digital/metrics').
      to_return(status: 200, body: response.to_json, headers: { 'Content-Type' => 'application/json' })
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
    message2 = build :message, base_path: '/base-path', attributes: { 'payload_version' => 1 }

    expect {
      subject.process(message)
      subject.process(message2)
    }.to change(Dimensions::Item, :count).by(1)

    expect(Dimensions::Item.first).to have_attributes(publishing_api_payload_version: 2)
  end

  it 'deprecates old items' do
    message = build :message, base_path: '/base-path', attributes: { 'payload_version' => 2 }
    message2 = build :message, base_path: '/base-path', attributes: { 'payload_version' => 4 }

    expect {
      subject.process(message)
      subject.process(message2)
    }.to change(Dimensions::Item, :count).by(2)

    expect(Dimensions::Item.find_by(publishing_api_payload_version: 2)).to have_attributes(latest: false)
    expect(Dimensions::Item.find_by(publishing_api_payload_version: 4)).to have_attributes(latest: true)
  end
end
