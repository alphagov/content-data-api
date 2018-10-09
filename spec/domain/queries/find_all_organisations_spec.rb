RSpec.describe Queries::FindAllOrganisations do
  context 'when we have data' do
    before do
      create :user
      create :edition, organisation_id: 'org-1-id', primary_organisation_title: 'z Org'
      create :edition, organisation_id: 'org-1-id', primary_organisation_title: 'z Org'
      create :edition, organisation_id: 'org-2-id', primary_organisation_title: 'a Org'
    end

    it 'returns distinct organisations ordered by primary_organisation_title' do
      results = described_class.retrieve
      expect(results.pluck(:primary_organisation_title, :organisation_id)).to eq([
                          ['a Org', 'org-2-id'],
                          ['z Org', 'org-1-id']
                        ])
    end
  end

  context 'when there is no data' do
    it 'returns an empty array' do
      expect(described_class.retrieve).to eq([])
    end
  end
end
