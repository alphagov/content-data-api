require 'rails_helper'

RSpec.describe OrganisationsService do
  describe '#find_each' do
    it 'queries the search API by organisation' do
      expected_params = { filter_format: 'organisation' }
      expect(Clients::SearchAPI).to receive(:find_each).with(expected_params, an_instance_of(Array))

      subject.find_each {}
    end
    it 'queries the search API by organisation' do
      expected_fields = %w(slug title)
      expect(Clients::SearchAPI).to receive(:find_each).with(an_instance_of(Hash), expected_fields)

      subject.find_each {}
    end
    it 'yields the content items' do
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
