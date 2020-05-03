RSpec.describe Etl::Edition::Content::Parser do
  subject { described_class }

  it "returns description if json does not have 'groups' key" do
    json = { schema_name: "service_manual_topic",
             description: "Blogs",
             details: {} }
    expect(subject.extract_content(json.deep_stringify_keys)).to eq("Blogs")
  end

  it "returns content json" do
    json = { schema_name: "service_manual_topic",
             description: "Blogs",
             details: { groups:
        [
          { name: "Design",
            description: "thinking" },
          { name: "Performance",
            description: "analysis" },
        ] } }
    expect(subject.extract_content(json.deep_stringify_keys)).to eq("Blogs Design thinking Performance analysis")
  end
end
