RSpec.describe Etl::Item::Content::Parser do
  subject { described_class.instance }

  it "returns content json if schema_name is 'statistics_announcement'" do
    json = { schema_name: "statistics_announcement",
      description: "Announcement",
      details: { display_date: "25 December 2017", state: "closed" } }
    expect(subject.extract_content(json.deep_stringify_keys)).to eq("Announcement 25 December 2017 closed")
  end
end
