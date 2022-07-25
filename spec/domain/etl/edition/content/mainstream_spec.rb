RSpec.describe Etl::Edition::Content::Parser do
  subject { described_class }

  it "returns content json if schema_name is 'mainstream_browse_page'" do
    json = { schema_name: "mainstream_browse_page",
             title: "Travel Abroad",
             description: "Go abroad",
             links: { children: [
                        { title: "Driving Abroad" },
                        { title: "Forced Marriage" },
                      ],
                      related_topics: [
                        { title: "Pets" },
                        { title: "Help" },
                      ] } }
    expected = "Travel Abroad Go abroad Driving Abroad Forced Marriage Pets Help"
    expect(subject.extract_content(json.deep_stringify_keys)).to eql(expected)
  end
end
