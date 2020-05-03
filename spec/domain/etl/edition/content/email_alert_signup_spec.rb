RSpec.describe Etl::Edition::Content::Parser do
  subject { described_class }

  describe "EmailAlertSignup" do
    it "returns summary if json does not have 'breadcrumbs' key" do
      json = { schema_name: "email_alert_signup",
               details: { summary: "Summary" } }
      expect(subject.extract_content(json.deep_stringify_keys)).to eq("Summary")
    end

    it "returns content json if schema_name is 'email_alert_signup'" do
      json = { schema_name: "email_alert_signup",
               details: { breadcrumbs: [{ title: "The title" }],
                          summary: "Summary" } }
      expect(subject.extract_content(json.deep_stringify_keys)).to eq("The title Summary")
    end
  end
end
