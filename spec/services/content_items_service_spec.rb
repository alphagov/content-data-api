require 'rails_helper'

RSpec.describe ContentItemsService do
  describe '#find_each' do
    before do
      allow(Clients::ContentStore).to receive(:find)
      allow(Clients::SearchAPI).to receive(:find_each)
    end

    it 'queries the search API, filtering by organisation' do
      expected_params = {
        query: { filter_organisations: 'organisation-slug' },
        fields: %w(link)
      }
      expect(Clients::SearchAPI).to receive(:find_each).with(expected_params)

      subject.find_each('organisation-slug') {}
    end

    it 'yields the response' do
      result = []
      allow(Clients::SearchAPI).to receive(:find_each).and_yield(link: :link1)
      allow(Clients::ContentStore).to receive(:find).and_return({})
      subject.find_each('organisation-slug') { |value| result << value }

      expect(result).to match_array([{ taxons: [] }])
    end

    it "does not yield nil responses from the content store" do
      result = []
      allow(Clients::SearchAPI).to receive(:find_each).and_yield(link: :link1)
      allow(Clients::ContentStore).to receive(:find).and_return(nil)
      subject.find_each('organisation-slug') { |value| result << value }

      expect(result).to match_array([])
    end


    it 'raises an exception if no block is passed' do
      expect { subject.find_each('organisation-slug') }.to raise_exception('missing block!')
    end
  end
end
