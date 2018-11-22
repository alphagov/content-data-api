RSpec.describe '/document_types' do
  before do
    create :user
    create :edition, document_type: 'guide'
    create :edition, document_type: 'manual'
    create :edition, document_type: 'manual'
    # `gone` and `redirect` should not appear in the results
    create :edition, document_type: 'redirect'
    create :edition, document_type: 'gone'
  end

  it 'returns distinct document types ordered by title' do
    get '/document_types'
    json = JSON.parse(response.body).deep_symbolize_keys
    expect(json).to eq(document_types: %w(guide manual))
  end

  include_examples 'API response', '/document_types'
end
