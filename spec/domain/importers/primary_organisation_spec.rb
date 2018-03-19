RSpec.describe Importers::PrimaryOrganisation do
  subject { described_class }
  it 'populates the primary org' do
    raw_json = {
      'links' => {
        'primary_publishing_organisation' => [
          {
            'content_id' => 'primary-cont-id',
            'title' => 'primary-title',
            'withdrawn' => false
          }
        ]
      }
    }
    expect(subject.parse(raw_json)).to eq(
      primary_organisation_content_id: 'primary-cont-id',
      primary_organisation_title: 'primary-title',
      primary_organisation_withdrawn: false
    )
  end

  it 'returns empty when links missing' do
    expect(subject.parse({})).to eq({})
  end

  it 'returns empty when links is empty' do
    expect(subject.parse('links' => {})).to eq({})
  end

  it 'returns empty when primary_publishing_organisation is empty' do
    expect(subject.parse('links' => { 'primary_publishing_organisation' => [] })).to eq({})
  end
end
