require 'rails_helper'

RSpec.describe Collectors::ContentItems do
  describe '#find_each' do
    before do
      allow(Clients::ContentStore).to receive(:find)
      allow_any_instance_of(Clients::SearchAPI).to receive(:find_each)
    end

    it 'queries the search API by organisation' do
      expected_params = { filter_organisations: 'organisation-slug' }
      expect_any_instance_of(Clients::SearchAPI).to receive(:find_each).with(expected_params, an_instance_of(Array))

      subject.find_each('organisation-slug') {}
    end
    it 'queries the search API by organisation' do
      expected_fields = %w(link)
      expect_any_instance_of(Clients::SearchAPI).to receive(:find_each).with(an_instance_of(Hash), expected_fields)

      subject.find_each('organisation-slug') {}
    end
    it 'yields the content items' do
      result = []
      allow_any_instance_of(Clients::SearchAPI).to receive(:find_each).and_yield(link: :link1)
      allow(Clients::ContentStore).to receive(:find).and_return(:a)
      subject.find_each('organisation-slug') { |value| result << value }

      expect(result).to eq([:a])
    end
    it 'retrieves attributes from the content store' do
      allow_any_instance_of(Clients::SearchAPI).to receive(:find_each).and_yield(link: :link1)
      expected_attributes = %i(content_id title public_updated_at document_type link)
      expect(Clients::ContentStore).to receive(:find).with(:link1, expected_attributes).and_return(:a)

      subject.find_each('organisation-slug') {}
    end
    it 'raises an exception if no block passed' do
      expect { subject.find_each('organisation-slug') }.to raise_exception('missing block!')
    end
  end
end
