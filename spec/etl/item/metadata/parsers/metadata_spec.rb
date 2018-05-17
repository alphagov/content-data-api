RSpec.describe Item::Metadata::Parsers::Metadata do
  subject { described_class }
  let(:raw_json) do
    { 'content_id' => '09hjasdfoj234',
      'base_path' => '/the/path',
      'locale' => 'en',
      'title' => 'A guide to coding',
      'document_type' => 'answer',
      'content_purpose_document_supertype' => 'guide',
      'content_purpose_supergroup' => 'guide',
      'content_purpose_subgroup' => 'guidance',
      'first_published_at' => '2012-10-03T13:19:55.000+00:00',
      'public_updated_at' => '2015-06-03T11:13:44.000+00:00' }
  end

  it 'parses the metadata correctly' do
    expect(subject.parse(raw_json)).to eq(
      title: 'A guide to coding',
      content_id: '09hjasdfoj234',
      base_path: '/the/path',
      locale: 'en',
      document_type: 'answer',
      content_purpose_document_supertype: 'guide',
      content_purpose_supergroup: 'guide',
      content_purpose_subgroup: 'guidance',
      first_published_at: '2012-10-03T13:19:55.000+00:00',
      public_updated_at: '2015-06-03T11:13:44.000+00:00'
)
  end
end
