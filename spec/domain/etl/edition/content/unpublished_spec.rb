RSpec.describe Etl::Edition::Content::Parser do
  subject { described_class }

  it "returns content json if schema_name is 'gone'" do
    json = { schema_name: "gone",
             details: { explanation: "No page here" } }
    expect(subject.extract_content(json.deep_stringify_keys)).to eq("No page here")
  end

  it "returns content json if schema_name is 'unpublishing'" do
    json = { schema_name: "unpublishing",
             details: { explanation: "This content has been removed" } }
    expect(subject.extract_content(json.deep_stringify_keys)).to eq("This content has been removed")
  end
end
