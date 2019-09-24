RSpec.describe Etl::Edition::Content::Parser do
  subject { described_class }

  it "returns content if schema name is 'need'" do
    json = {
      schema_name: "need",
      details: {
        role: "the role",
        goal: "the goal",
        benefit: "the benefit",
      },
    }
    expect(subject.extract_content(json.deep_stringify_keys)).to eq("the role the goal the benefit")
  end
end
