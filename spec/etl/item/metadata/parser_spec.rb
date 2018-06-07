RSpec.describe Item::Metadata::Parser do
  let(:raw_json) { { 'details' => 'the-json' } }
  let(:content_hash) { '94e66df8cd09d410c62d9e0dc59d3a884e458e05' }
  subject { described_class.instance }
  before :each do
    allow(Item::Metadata::Parsers::NumberOfPdfs).to receive(:parse).with(raw_json).and_return(number_of_pdfs: 99)
    allow(Item::Metadata::Parsers::NumberOfWordFiles).to receive(:parse).with(raw_json).and_return(number_of_word_files: 94)
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
    expect(Item::Metadata::Parsers::NumberOfPdfs).to have_received(:parse).with(raw_json)
  end

  it 'returns the number of Word file attachments' do
    expect(subject.parse(raw_json)).to include(
      number_of_word_files: 94
    )
    expect(Item::Metadata::Parsers::NumberOfWordFiles).to have_received(:parse).with(raw_json)
  end
end
