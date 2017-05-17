RSpec.describe OrganisationsService do
  describe '#find_each' do
    it 'queries the publishing API for all organisations' do
      expected_field_params = %i(base_path title content_id)
      expected_query_params = { document_type: 'organisation' }

      subject.publishing_api = double
      expect(subject.publishing_api).to receive(:find_each).with(expected_field_params, expected_query_params)

      subject.find_each {}
    end

    it 'yields the response with the base_path mapped to slug' do
      result = []
      subject.publishing_api = double
      allow(subject.publishing_api).to receive(:find_each).and_yield(base_path: "/government/organisations/slug-1").and_yield(base_path: "/government/organisations/slug-2")

      subject.find_each { |value| result << value }

      expect(result).to match_array([{ slug: "slug-1" }, { slug: "slug-2" }])
    end

    it 'raises an exception if no block passed' do
      expect { subject.find_each }.to raise_exception('missing block!')
    end
  end
end
