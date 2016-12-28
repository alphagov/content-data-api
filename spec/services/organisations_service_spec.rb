require 'rails_helper'

RSpec.describe OrganisationsService do
  describe '#find_each' do
    it 'queries the search API for all organisations' do
      expected_params = {
        query: { filter_format: 'organisation' },
        fields: %w(slug title)
      }
      expect(Clients::SearchAPI).to receive(:find_each).with(expected_params)

      subject.find_each {}
    end

    it 'yields the response' do
      result = []
      allow(Clients::SearchAPI).to receive(:find_each).and_yield(:a).and_yield(:b)
      subject.find_each { |value| result << value }

      expect(result).to eq([:a, :b])
    end

    it 'raises an exception if no block passed' do
      expect { subject.find_each }.to raise_exception('missing block!')
    end
  end
end
