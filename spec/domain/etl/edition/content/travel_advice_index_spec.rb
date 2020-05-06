RSpec.describe Etl::Edition::Content::Parser do
  subject { described_class }

  it "returns nil if json does not have children array" do
    json = { schema_name: "travel_advice_index",
             links: {} }
    expect(subject.extract_content(json.deep_stringify_keys)).to eq(nil)
  end

  it "returns content json" do
    json = { schema_name: "travel_advice_index",
             links: { children: [
               { country: { name: "Portugal" } },
               { country: { name: "Brazil" } },
             ] } }
    expect(subject.extract_content(json.deep_stringify_keys)).to eq("Portugal Brazil")
  end
end
