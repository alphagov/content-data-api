require 'rails_helper'

RSpec.describe Clients::SearchAPI do
  subject { Clients::SearchAPI }

  let(:two_content_items) {
    double(body: {
      results: [
        {
          content_id: 'content-id-1',
          link: '/item/1/path',
          title: 'title-1',
        },
        {
          content_id: 'content-id-2',
          link: '/item/2/path',
          title: 'title-2'
        }
      ]
    }.to_json)
  }

  let(:one_content_item) {
    double(body: {
      results: [
        {
          content_id: 'content-id-1',
          link: '/item/1/path',
          title: 'title-1',
        }
      ]
    }.to_json)
  }

  let(:empty_response) {
    double(body: { results: [] }.to_json)
  }

  describe 'symbolized attributes' do
    let(:response) { double(body: { results: [{ 'title' => 'title-1', 'link' => 'a-link' }] }.to_json) }

    it 'return the requested attributes symbolized' do
      allow(HTTParty).to receive(:get).and_return(response)

      subject.find_each({ param: :value1 }, %w(title)) do |attributes|
        expect(attributes).to eq(title: 'title-1')
      end
    end
  end

  describe 'making API calls with HTTParty' do
    it 'queries the search API with the organisation\'s slug' do
      expected_url = 'https://www.gov.uk/api/search.json?param=value1&fields=field1%2Cfield2&count=99&start=0'
      expect(HTTParty).to receive(:get).once.with(expected_url).and_return(empty_response)

      allow(subject).to receive(:batch_size).and_return(99)
      subject.find_each({ param: :value1 }, %w(field1 field2)) {}
    end
  end

  context 'Pagination' do
    it 'paginates through all the content items for an organisation' do
      another_content_item = double(body: {
        results: [
          {
            content_id: 'content-id-3',
            link: '/item/3/path',
            title: 'title-3',
          }
        ]
      }.to_json)

      expect(HTTParty).to receive(:get).twice.and_return(two_content_items, another_content_item)
      allow(subject).to receive(:batch_size).and_return(2)

      expect { |b| subject.find_each({}, [], &b) }.to yield_control.exactly(3).times
    end

    it 'handles last page with 0 results when organisation already has content items' do
      expect(HTTParty).to receive(:get).exactly(2).times.and_return(one_content_item, empty_response)
      allow(subject).to receive(:batch_size).and_return(1)

      expect { |b| subject.find_each({}, [], &b) }.to yield_control.exactly(1).times
    end
  end
end
