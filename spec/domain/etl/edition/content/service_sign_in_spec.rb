RSpec.describe Etl::Edition::Content::Parser do
  subject { described_class }

  it "returns content json if schema_name is 'service_sign_in'" do
    json = { schema_name: "service_sign_in",
             details: {
               choose_sign_in: { title: "Proof",
                                 options: [
                                   { text: "Use Gateway", hint_text: "You have a user ID" },
                                   { text: "Use Verify", hint_text: "You have an account" },
                                 ] },
               create_new_account: { title: "Create", body: "Click here" },
             } }
    expected = "Proof Use Gateway You have a user ID Use Verify You have an account Create Click here"
    expect(subject.extract_content(json.deep_stringify_keys)).to eq(expected)
  end
end
