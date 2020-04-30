RSpec.describe Etl::Edition::Content::Parser do
  subject { described_class }

  it "returns content json if schema_name is 'finder'" do
    json = { schema_name: "finder", title: "Contact HMRC",
             links: { children: [
        { title: "Personal Tax", description: "Email, write or phone us" },
        { title: "Child Benefit", description: "Tweet us" },
      ] } }
    expected = "Contact HMRC Personal Tax Email, write or phone us Child Benefit Tweet us"
    expect(subject.extract_content(json.deep_stringify_keys)).to eql(expected)
  end
end
