RSpec.describe Metadata::Parser do
  let(:raw_json) { { 'details' => 'the-json' } }

  subject { described_class.instance }
  before :each do
    allow(Metadata::Parsers::NumberOfPdfs).to receive(:parse).with(raw_json).and_return(number_of_pdfs: 99)
    allow(Metadata::Parsers::NumberOfWordFiles).to receive(:parse).with(raw_json).and_return(number_of_word_files: 94)
    allow(Metadata::Parsers::Metadata).to receive(:parse).and_return(
      'content_id' => '09hjasdfoj234',
      'title' => 'A guide to coding',
      'document_type' => 'answer',
      'content_purpose_document_supertype' => 'guide',
      'first_published_at' => '2012-10-03T13:19:55.000+00:00',
      'public_updated_at' => '2015-06-03T11:13:44.000+00:00',
    )
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
    expect(Metadata::Parsers::NumberOfPdfs).to have_received(:parse).with(raw_json)
  end

  it 'returns the number of Word file attachments' do
    expect(subject.parse(raw_json)).to include(
      number_of_word_files: 94
    )
    expect(Metadata::Parsers::NumberOfWordFiles).to have_received(:parse).with(raw_json)
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
    expect(Metadata::Parsers::Metadata).to have_received(:parse).with(raw_json)
  end
end
