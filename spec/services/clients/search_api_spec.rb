require 'rails_helper'

RSpec.describe Clients::SearchAPI do
  subject { Clients::SearchAPI }

  let(:two_content_items) {
    { results: [
      { content_id: 'content-id-1' },
      { content_id: 'content-id-2' },
    ] }.to_json
  }

  let(:one_content_item) { { results: [{ content_id: 'content-id-1' }] }.to_json }
  let(:empty_response) { { results: [] }.to_json }

  it 'returns symbolized attributes' do
    response = { results: [{ 'title' => 'title-1' }] }.to_json
    stub_request(:get, %r{.*}).to_return(:status => 200, :body => response)

    subject.find_each(query: { param: :value1 }, fields: %w(title)) do |attributes|
      expect(attributes).to eq(title: 'title-1')
    end
  end

  it 'builds the SearchAPI query' do
    stub_request(:get, "https://www.gov.uk/api/search.json?count=1000&fields=field1,field2&param=value1&start=0")
      .to_return(:status => 200, :body => { results: [] }.to_json)

    subject.find_each(query: { param: :value1 }, fields: %w(field1 field2)) {}

    expect(WebMock).to have_requested(:get, "https://www.gov.uk/api/search.json?count=1000&fields=field1,field2&param=value1&start=0")
  end

  context 'when multiples pages' do
    it 'iterates through the pages' do
      another_content_item = { results: [{ content_id: 'content-id-3' }] }.to_json

      stub_request(:get, %r{.*}).to_return(
        { :status => 200, :body => two_content_items },
        { :status => 200, :body => another_content_item }
      )

      allow(subject).to receive(:batch_size).and_return(2)

      expect { |b| subject.find_each(query: {}, fields: [], &b) }.to yield_control.exactly(3).times
    end

    it 'does not fail when last page size is equal to batch size' do
      stub_request(:get, %r{.*}).to_return(
        { :status => 200, :body => one_content_item },
        { :status => 200, :body => empty_response }
      )

      allow(subject).to receive(:batch_size).and_return(1)

      expect { |b| subject.find_each(query: {}, fields: [], &b) }.to yield_control.exactly(1).times
    end
  end
end
