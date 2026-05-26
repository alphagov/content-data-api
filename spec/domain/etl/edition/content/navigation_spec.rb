RSpec.describe Etl::Edition::Content::Parser do
  subject { described_class }

  it "returns content if schema name is 'navigation'" do
    json = {
      schema_name: "navigation",
      details: {
        menu_items: [
          { content_id: "abc123" },
          { content_id: "def456" },
        ],
      },
    }
    expected = [
      "abc123 def456",
    ].join(" ")
    expect(subject.extract_content(json.deep_stringify_keys)).to eq(expected)
  end
end
