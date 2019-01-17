RSpec.describe Finders::FindMetadata do
  let!(:base_path) { '/base_path' }

  before do
    create :edition,
      latest: true,
      title: 'the title',
      base_path: base_path,
      content_id: 'content_id - 1',
      document_type: 'guide',
      publishing_app: 'whitehall',
      first_published_at: '2018-07-17T10:35:59.000Z',
      public_updated_at: '2018-07-17T10:35:57.000Z',
      primary_organisation_title: 'The ministry',
      withdrawn: false,
      historical: false

    create :edition,
      latest: false,
      title: 'the old title',
      base_path: base_path,
      document_type: 'guide',
      publishing_app: 'whitehall',
      first_published_at: '2018-06-17T10:35:59.000Z',
      public_updated_at: '2018-06-17T10:35:57.000Z',
      primary_organisation_title: 'The ministry',
      withdrawn: false,
      historical: false
  end

  it "returns metadata for latest edition" do
    metadata = described_class.run('/base_path')

    expect(metadata).to eq(
      title: 'the title',
      base_path: base_path,
      content_id: 'content_id - 1',
      document_type: 'guide',
      publishing_app: 'whitehall',
      first_published_at: '2018-07-17T10:35:59.000Z',
      public_updated_at: '2018-07-17T10:35:57.000Z',
      primary_organisation_title: 'The ministry',
      withdrawn: false,
      historical: false,
      parent_content_id: ''
    )
  end

  it "returns nil for invalid base path" do
    metadata = described_class.run('/does_not_exist')
    expect(metadata).to eq(nil)
  end
end
