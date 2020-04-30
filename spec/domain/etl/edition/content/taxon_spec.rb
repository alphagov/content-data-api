RSpec.describe Etl::Edition::Content::Parser do
  subject { described_class }

  it "returns description if json does not have any child_taxons" do
    json = { schema_name: "taxon",
             description: "Blogs",
             links: {} }
    expect(subject.extract_content(json.deep_stringify_keys)).to eq("Blogs")
  end

  it "returns content json if schema_name is 'taxon'" do
    json = { schema_name: "taxon",
             description: "Blogs",
             links: { child_taxons: [
        { title: "One", description: "first" },
        { title: "Two", description: "second" },
      ] } }
    expect(subject.extract_content(json.deep_stringify_keys)).to eq("Blogs One first Two second")
  end
end
