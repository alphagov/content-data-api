RSpec.describe '/organisations' do
  before do
    create :user
    create :edition, organisation_id: 'org-1-id', primary_organisation_title: 'z Org'
    create :edition, organisation_id: 'org-1-id', primary_organisation_title: 'z Org'
    create :edition, organisation_id: 'org-2-id', primary_organisation_title: 'a Org'
  end

  it 'returns distinct organisations ordered by title' do
    get '/organisations'
    json = JSON.parse(response.body).deep_symbolize_keys
    expect(json).to eq(
      organisations: [
        { title: 'a Org', organisation_id: 'org-2-id' },
        { title: 'z Org', organisation_id: 'org-1-id' }
      ]
    )
  end
end
