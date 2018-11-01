RSpec.describe Queries::FindAllOrganisations do
  context 'when we have data' do
    before do
      create :user
      create :edition, document_type: 'organisation', content_id: 'org-1-id', title: 'z Org'
      create :edition, document_type: 'organisation', content_id: 'org-2-id', title: 'a Org'
    end

    it 'returns distinct organisations ordered by primary_organisation_title' do
      results = described_class.retrieve
      expect(results).to eq([
                            { title: 'a Org', organisation_id: 'org-2-id' },
                            { title: 'z Org', organisation_id: 'org-1-id' }
                          ])
    end
  end

  context 'when there is no data' do
    it 'returns an empty array' do
      expect(described_class.retrieve).to eq([])
    end
  end
end
