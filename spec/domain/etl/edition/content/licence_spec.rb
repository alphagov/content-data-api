RSpec.describe Etl::Edition::Content::Parser do
  subject { described_class }

  it "returns content json if schema is 'licence'" do
    json = { schema_name: "licence",
             details: { licence_overview: "licence expired" } }
    expect(subject.extract_content(json.deep_stringify_keys)).to eq("licence expired")
  end

  it "returns nil if details.body is an empty string" do
    json = { schema_name: "licence", details: { licence_overview: "" } }
    expect(subject.extract_content(json.deep_stringify_keys)).to eq(nil)
  end

  it "returns nil if details.body is an empty array" do
    valid_schema_json = { schema_name: "licence", details: { licence_overview: [] } }
    expect(subject.extract_content(valid_schema_json.deep_stringify_keys)).to eq(nil)
  end

  it "returns licence_overview for content provided as array for each content type" do
    json = { schema_name: "licence",
             details: { licence_overview:
        [
          {
            "content_type": "text/govspeak",
            "content": "licence expired one",
          },
          {
            "content_type": "text/html",
            "content": "licence expired two",
          },
        ] } }

    expect(subject.extract_content(json.deep_stringify_keys)).to eq("licence expired two")
  end
end
