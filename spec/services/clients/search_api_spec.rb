require 'rails_helper'

RSpec.describe Clients::SearchAPI do
  subject { Clients::SearchAPI }

  let(:two_content_items) {
    double(body: { results: [
      { content_id: 'content-id-1' },
      { content_id: 'content-id-2' },
    ] }.to_json)
  }

  let(:one_content_item) { double(body: { results: [{ content_id: 'content-id-1' }] }.to_json) }
  let(:empty_response) { double(body: { results: [] }.to_json) }

  it 'returns symbolized attributes' do
    response = double(body: { results: [{ 'title' => 'title-1' }] }.to_json)
    allow(HTTParty).to receive(:get).and_return(response)

    subject.find_each({ param: :value1 }, %w(title)) do |attributes|
      expect(attributes).to eq(title: 'title-1')
    end
  end

  it 'builds the SearchAPI query' do
    expected_url = 'https://www.gov.uk/api/search.json?param=value1&fields=field1%2Cfield2&count=1000&start=0'
    expect(HTTParty).to receive(:get).with(expected_url).and_return(empty_response)

    subject.find_each({ param: :value1 }, %w(field1 field2)) {}
  end

  context 'when multile pages' do
    it 'paginates through the response' do
      another_content_item = double(body: { results: [{ content_id: 'content-id-3' }] }.to_json)

      expect(HTTParty).to receive(:get).twice.and_return(two_content_items, another_content_item)
      allow(subject).to receive(:batch_size).and_return(2)

      expect { |b| subject.find_each({}, [], &b) }.to yield_control.exactly(3).times
    end

    it 'does not fail when last page has 0 results' do
      expect(HTTParty).to receive(:get).exactly(2).times.and_return(one_content_item, empty_response)
      allow(subject).to receive(:batch_size).and_return(1)

      expect { |b| subject.find_each({}, [], &b) }.to yield_control.exactly(1).times
    end
  end
end
