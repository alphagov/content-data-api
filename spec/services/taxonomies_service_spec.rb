require 'rails_helper'

RSpec.describe TaxonomiesService do
  describe '#find_each' do
    it 'queries the publishing API for the given fields' do
      subject.publishing_api = double
      expected_params = %i(content_id title)

      expect(subject.publishing_api).to receive(:find_each).with(expected_params)

      subject.find_each {}
    end
  end
end
