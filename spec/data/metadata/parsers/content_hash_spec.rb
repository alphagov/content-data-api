require 'digest/sha1'
RSpec.describe Metadata::Parsers::ContentHash do
  subject { described_class }

  let(:content) { 'some content' }
  let(:raw_json) { { some: 'json' } }

  it "returns the hash of the content as 'content_hash'" do
    allow(Content::Parser).to receive(:extract_content).and_return(content)

    expect(subject.parse(raw_json)).to eq(content_hash: Digest::SHA1.hexdigest(content))
    expect(Content::Parser).to have_received(:extract_content).with(raw_json)
  end

  it 'returns { content_hash: nil } if no JSON is passed' do
    expect(subject.parse(nil)).to eq(content_hash: nil)
  end

  it 'returns { content_hash: nil } if JSON is provided by it has no content' do
    allow(Content::Parser).to receive(:extract_content).and_return(nil)

    expect(subject.parse(:some_json)).to eq(content_hash: nil)
  end
end
