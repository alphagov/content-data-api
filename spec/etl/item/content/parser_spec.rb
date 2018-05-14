RSpec.describe Item::Content::Parser do
  subject { described_class.instance }

  describe "#extract_content" do
    context "when valid schema" do
      describe "ServiceManualTopic" do
        it "returns description if json does not have 'groups' key" do
          json = { schema_name: "service_manual_topic",
            description: "Blogs",
            details: {} }
          expect(subject.extract_content(json.deep_stringify_keys)).to eq("Blogs")
        end

        it "returns content json" do
          json = { schema_name: "service_manual_topic",
            description: "Blogs",
            details: { groups:
              [
                { name: "Design",
                  description: "thinking" },
                { name: "Performance",
                  description: "analysis" }
              ] } }
          expect(subject.extract_content(json.deep_stringify_keys)).to eq("Blogs Design thinking Performance analysis")
        end
      end

      it "returns content json if schema_name is 'service_sign_in'" do
        json = { schema_name: "service_sign_in",
          details: {
            choose_sign_in: { title: "Proof",
              options: [
                { text: "Use Gateway", hint_text: "You have a user ID" },
                { text: "Use Verify", hint_text: "You have an account" },
              ] },
            create_new_account: { title: "Create", body: "Click here" }
          } }
        expected = "Proof Use Gateway You have a user ID Use Verify You have an account Create Click here"
        expect(subject.extract_content(json.deep_stringify_keys)).to eq(expected)
      end

      it "returns content json if schema_name is 'service_manual_homepage'" do
        json = { schema_name: "service_manual_homepage", title: "Service Manual",
          description: "Digital Service Standard",
          links: { children: [
            { title: "Design", description: "Naming your service" },
            { title: "Technology", description: "Security and Maintenance" }
            ] } }

        expected = "Service Manual Digital Service Standard Design Naming your service Technology Security and Maintenance"
        expect(subject.extract_content(json.deep_stringify_keys)).to eql(expected)
      end
    end

    context "when invalid schema" do
      describe "has no schema_name and no base_path" do
        it "raises an InvalidSchemaError and returns nil" do
          subject.extract_content document_type: 'answer'
          expect(GovukError).to receive(:notify).with(InvalidSchemaError.new("Schema does not exist: "), extra: { base_path: "" })
          expect(subject.extract_content(document_type: 'answer')).to be_nil
        end
      end

      describe "has an unknown schema_name but no base_path" do
        it "logs InvalidSchemaError with the schema_name" do
          json = { schema_name: "blah", links: {} }

          expect(GovukError).to receive(:notify).with(InvalidSchemaError.new("Schema does not exist: blah"), extra: { base_path: "" })

          result = subject.extract_content(json.deep_stringify_keys)
          expect(result).to be_nil
        end
      end

      describe "has an unknown schema_name and a base_path" do
        it "raises InvalidSchemaError with the schema and the base_path" do
          json = { base_path: "/unknown/base_path", schema_name: "unknown",
            links: {} }
          subject.extract_content(json.deep_stringify_keys)
          expect(GovukError).to receive(:notify).with(InvalidSchemaError.new("Schema does not exist: unknown"), extra: { base_path: "/unknown/base_path" })
          expect(subject.extract_content(json.deep_stringify_keys)).to be_nil
        end
      end
    end
  end
end
