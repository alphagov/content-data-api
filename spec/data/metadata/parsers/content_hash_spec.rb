require 'digest/sha1'
RSpec.describe Metadata::Parsers::ContentHash do
  subject { described_class }

  let(:content) { 'some content' }
  let(:raw_json) { { some: 'json' } }

  before :each do
    allow(Content::Parser).to receive(:extract_content).and_return(content)
  end

  it "returns the hash of the content as 'content_hash'" do
    expect(subject.parse(raw_json)).to eq(
      content_hash: Digest::SHA1.hexdigest(content)
    )
    expect(Content::Parser).to have_received(:extract_content).with(raw_json)
  end
end
