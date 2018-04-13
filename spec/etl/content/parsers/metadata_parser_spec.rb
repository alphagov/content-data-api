RSpec.describe Content::Parsers::MetadataParser do
  let(:raw_json) { { 'details' => 'the-json' } }
  let(:content_hash) { '94e66df8cd09d410c62d9e0dc59d3a884e458e05' }
  subject { described_class.instance }
  before :each do
    allow(Content::Parsers::Metadata::NumberOfPdfs).to receive(:parse).with(raw_json).and_return(number_of_pdfs: 99)
    allow(Content::Parsers::Metadata::NumberOfWordFiles).to receive(:parse).with(raw_json).and_return(number_of_word_files: 94)
    allow(Content::Parsers::Metadata::Metadata).to receive(:parse).and_return(
      'content_id' => '09hjasdfoj234',
      'title' => 'A guide to coding',
      'document_type' => 'answer',
      'content_purpose_document_supertype' => 'guide',
      'first_published_at' => '2012-10-03T13:19:55.000+00:00',
      'public_updated_at' => '2015-06-03T11:13:44.000+00:00',
    )
    allow(Content::Parsers::Metadata::ContentHash).to receive(:parse).and_return(content_hash: content_hash)
  end

  it 'populates raw_json field of latest version of dimensions_items' do
    expect(subject.parse(raw_json)).to include(
      raw_json: raw_json
    )
  end

  it 'returns the number of PDF attachments' do
    expect(subject.parse(raw_json)).to include(
      number_of_pdfs: 99
    )
    expect(Content::Parsers::Metadata::NumberOfPdfs).to have_received(:parse).with(raw_json)
  end

  it 'returns the number of Word file attachments' do
    expect(subject.parse(raw_json)).to include(
      number_of_word_files: 94
    )
    expect(Content::Parsers::Metadata::NumberOfWordFiles).to have_received(:parse).with(raw_json)
  end

  it 'populates the metadata' do
    expect(subject.parse(raw_json)).to include(
      'content_id' => '09hjasdfoj234',
      'title' => 'A guide to coding',
      'document_type' => 'answer',
      'content_purpose_document_supertype' => 'guide',
      'first_published_at' => '2012-10-03T13:19:55.000+00:00',
      'public_updated_at' => '2015-06-03T11:13:44.000+00:00'
    )
    expect(Content::Parsers::Metadata::Metadata).to have_received(:parse).with(raw_json)
  end

  it 'populates the content hash' do
    expect(subject.parse(raw_json)).to include(
      content_hash: content_hash
    )
    expect(Content::Parsers::Metadata::ContentHash).to have_received(:parse).with(raw_json)
  end
end
