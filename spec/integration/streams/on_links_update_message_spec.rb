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

  it 'does not notify error if old item is missing `expanded_links`' do
    item = create(:dimensions_item, expanded_links: nil)
    message = build(:message, :link_update)
    message.payload['content_id'] = item.content_id
    message.payload['publishing_api_payload_version'] = item.publishing_api_payload_version + 1
    message.payload['base_path'] = item.base_path

    expect(GovukError).not_to receive(:notify)
    subject.process(message)
  end

  it 'discard the event if no real link changes' do
    expect(GovukError).to_not receive(:notify)

    message = build(:message)
    subject.process(message)

    link_update = build :message, :link_update, payload: message.payload
    link_update.payload['payload_version'] = 1000000000000
    expect {
      subject.process(link_update)
    }.to change(Dimensions::Item, :count).by(0)
    expect(Dimensions::Item.first).to have_attributes(latest: true)
  end

  it 'grows the dimension with when links change' do
    expect(GovukError).to_not receive(:notify)

    message = build(:message)
    subject.process(message)

    link_update = build :message, :link_update, payload: message.payload
    link_update.payload['payload_version'] = 1000000000000
    link_update.payload['expanded_links']['primary_publishing_organisation'] = [
      {
        'content_id' => 'ce91c056-8165-49fe-b318-b71113ab4a30',
        'title' => 'the-title',
        'withdrawn' => 'false',
        'locale' => 'en',
        'base_path' => '/the-base-path'
      }
    ]
    expect {
      subject.process(link_update)
    }.to change(Dimensions::Item, :count).by(1)
  end

  it 'does not grow the dimension when same links in different order' do
    expect(GovukError).to_not receive(:notify)
    expanded_links = [
     {
       'content_id' => 'aaaaaaaa-8165-49fe-b318-b71113ab4a30',
       'title' => 'the-title-a',
       'base_path' => '/the-base-path-a'
     },
     {
       'content_id' => 'bbbbbbbb-8165-49fe-b318-b71113ab4a30',
       'title' => 'the-title-b',
       'base_path' => '/the-base-path-b'
     },
    ]

    message = build(:message)
    message.payload['payload_version'] = 1
    message.payload['expanded_links']['primary_publishing_organisation'] = expanded_links
    subject.process(message)

    link_update = build :message, :link_update, payload: message.payload
    link_update.payload['payload_version'] = 2
    link_update.payload['expanded_links']['primary_publishing_organisation'] = expanded_links.reverse
    expect {
      subject.process(link_update)
    }.to change(Dimensions::Item, :count).by(0)
  end

  it 'does not raise error if `old_item` does not exist' do
    expect(GovukError).to_not receive(:notify)

    link_update = build :message, :link_update
    link_update.payload['payload_version'] = 2
    link_update.payload['expanded_links'] = nil
    expect {
      subject.process(link_update)
    }.to_not raise_error
  end

  it 'does not raise error if `expanded_links` field is empty' do
    expect(GovukError).to_not receive(:notify)

    message = build(:message)
    message.payload['payload_version'] = 1
    message.payload['expanded_links'] = {}
    subject.process(message)

    link_update = build :message, :link_update, payload: message.payload
    link_update.payload['payload_version'] = 2
    link_update.payload['expanded_links'] = {}
    expect {
      subject.process(link_update)
    }.to_not raise_error
  end
end
