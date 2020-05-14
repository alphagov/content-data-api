RSpec.describe Etl::Edition::Content::Parser do
  subject { described_class }

  it "returns content json if schema_name is 'local_transaction'" do
    json = { schema_name: "local_transaction",
             details: { introduction: "Greetings",
                        need_to_know: "A Name",
                        more_information: "An Address" } }
    expect(subject.extract_content(json.deep_stringify_keys)).to eq("Greetings A Name An Address")
  end
end
