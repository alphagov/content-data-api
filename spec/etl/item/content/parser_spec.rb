RSpec.describe Item::Content::Parser do
  subject { described_class.instance }

  describe "#extract_content" do
    context "when valid schema" do
      it "returns content json if schema_name is 'local_transaction'" do
        json = { schema_name: "local_transaction",
          details: { introduction: "Greetings", need_to_know: "A Name",
            more_information: "An Address" } }
        expect(subject.extract_content(json.deep_stringify_keys)).to eq("Greetings A Name An Address")
      end

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

      it "returns content json if schema_name is 'statistics_announcement'" do
        json = { schema_name: "statistics_announcement",
          description: "Announcement",
          details: { display_date: "25 December 2017", state: "closed" } }
        expect(subject.extract_content(json.deep_stringify_keys)).to eq("Announcement 25 December 2017 closed")
      end

      describe "ServiceManualStandard" do
        it "returns title and body if json does not have 'children' key" do
          json = {
            schema_name: 'service_manual_service_standard',
            title: 'sm title',
            details: { body: 'the main body' },
            links: {}
          }
          expect(subject.extract_content(json.deep_stringify_keys)).to eq('sm title the main body')
        end

        it "returns content if schema_name is 'service_manual_service_standard'" do
          json = {
            schema_name: 'service_manual_service_standard',
            title: 'sm title',
            details: { body: 'the main body' },
            links: {
              children: [
                { title: 'ch1 title', description: 'ch1 desc' },
                { title: 'ch2 title', description: 'ch2 desc' }
              ]
            }
          }
          expect(subject.extract_content(json.deep_stringify_keys)).to eq('sm title the main body ch1 title ch1 desc ch2 title ch2 desc')
        end
      end

      describe "ServiceManualServiceToolkit" do
        it "returns nil if json does not have 'collection' key" do
          json = {
            schema_name: 'service_manual_service_toolkit',
            details: {}
          }
          expect(subject.extract_content(json.deep_stringify_keys)).to eq(nil)
        end

        it "returns 'title' and 'description' if json does not have 'links' key" do
          json = {
            schema_name: 'service_manual_service_toolkit',
            details: {
              collections: [
                {
                  title: 'main title 1',
                  description: 'main desc 1'
                }
              ]
            }
          }
          expect(subject.extract_content(json.deep_stringify_keys)).to eq('main title 1 main desc 1')
        end

        it "returns json content" do
          json = {
            schema_name: 'service_manual_service_toolkit',
            details: {
              collections: [
                {
                  title: 'main title 1',
                  description: 'main desc 1',
                  links: [
                    { title: 'title link 1', description: 'desc link 1' },
                    { title: 'title link 2', description: 'desc link 2' }
                  ]
                }
              ]
            }
          }
          expect(subject.extract_content(json.deep_stringify_keys)).to eq('main title 1 main desc 1 title link 1 desc link 1 title link 2 desc link 2')
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
