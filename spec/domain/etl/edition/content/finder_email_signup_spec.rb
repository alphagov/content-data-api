RSpec.describe Etl::Edition::Content::Parser do
  subject { described_class }

  describe "FinderEmailSignup" do
    it "returns description if json does not have 'email_signup_choice' key" do
      json = { schema_name: "finder_email_signup",
               description: "Use buttons",
               details: {} }
      expect(subject.extract_content(json.deep_stringify_keys)).to eq("Use buttons")
    end

    it "returns content json" do
      json = { schema_name: "finder_email_signup",
               description: "Use buttons",
               details: { email_signup_choice:
          [
            { radio_button_name: "Yes" },
            { radio_button_name: "No" },
          ] } }
      expect(subject.extract_content(json.deep_stringify_keys)).to eq("Yes No Use buttons")
    end
  end
end
