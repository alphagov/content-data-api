RSpec.describe Etl::Edition::Content::Parser do
  subject { described_class }

  it "returns content json if schema_name is 'service_manual_homepage'" do
    json = { schema_name: "service_manual_homepage", title: "Service Manual",
             description: "Digital Service Standard",
             links: { children: [
        { title: "Design", description: "Naming your service" },
        { title: "Technology", description: "Security and Maintenance" },
        ] } }

    expected = "Service Manual Digital Service Standard Design Naming your service Technology Security and Maintenance"
    expect(subject.extract_content(json.deep_stringify_keys)).to eql(expected)
  end
end
