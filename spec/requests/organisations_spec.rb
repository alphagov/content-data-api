RSpec.describe '/organisations' do
  before do
    create :user
    create :edition, document_type: 'organisation', content_id: 'org-1-id', title: 'z Org'
    create :edition, document_type: 'organisation', content_id: 'org-2-id', title: 'a Org'
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

  include_examples 'API response', '/organisations'
end
