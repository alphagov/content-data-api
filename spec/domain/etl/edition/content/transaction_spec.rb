RSpec.describe Etl::Edition::Content::Parser do
  subject { described_class }

  it "returns content json if schema_name is 'transaction'" do
    json = { schema_name: "transaction",
             details: { introductory_paragraph: "Report changes",
                        start_button_text: "Start",
                        will_continue_on: "Carer's Allowance service",
                        more_information: "Facts" } }
    expected = "Report changes Start Carer's Allowance service Facts"
    expect(subject.extract_content(json.deep_stringify_keys)).to eq(expected)
  end
end
