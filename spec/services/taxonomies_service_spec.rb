RSpec.describe TaxonomiesService do
  describe '#find_each' do
    it 'queries the publishing API for the given fields of taxons' do
      subject.publishing_api = double
      field_params = %i(content_id title)
      query_params = { document_type: "taxon" }

      expect(subject.publishing_api).to receive(:find_each).with(field_params, query_params)

      subject.find_each {}
    end
  end
end
