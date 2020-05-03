RSpec.describe Etl::Edition::Content::Parser do
  subject { described_class }

  it "returns content json if schema is 'place'" do
    json = { schema_name: "place",
             details: { introduction: "Introduction",
                        more_information: "Enter your postcode" } }
    expect(subject.extract_content(json.deep_stringify_keys)).to eq("Introduction Enter your postcode")
  end
end
