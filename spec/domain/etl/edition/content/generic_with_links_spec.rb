RSpec.describe Etl::Edition::Content::Parser do
  subject { described_class }

  it "returns nil if json does not have 'external_related_links' key" do
    json = { schema_name: "generic_with_external_related_links",
             details: {} }
    expect(subject.extract_content(json.deep_stringify_keys)).to eq(nil)
  end

  it "returns content json if schema_name is 'generic_with_external_related_links'" do
    json = { schema_name: "generic_with_external_related_links",
             details: { external_related_links: [
               { title: "Check your Council Tax band" },
             ] } }
    expect(subject.extract_content(json.deep_stringify_keys)).to eq("Check your Council Tax band")
  end
end
