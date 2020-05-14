RSpec.describe Etl::Edition::Content::Parser do
  subject { described_class }

  describe "#extract_content" do
    context "when valid schema" do
      describe "extraction fails with a StandardError" do
        it "logs the error with Sentry" do
          json = { schema_name: "place",
                   details: { introduction: "Introduction",
                              more_information: "Enter your postcode" } }.deep_stringify_keys

          allow(Nokogiri::HTML).to receive(:parse).and_raise(StandardError)

          expect(GovukError).to receive(:notify)
          subject.extract_content(json)
        end
      end
    end

    it "returns nil if json is empty" do
      content = subject.extract_content({})
      expect(content).to be_nil
    end

    context "when invalid schema" do
      describe "has no schema_name and no base_path" do
        it "raises an InvalidSchemaError and returns nil" do
          subject.extract_content(document_type: "answer")
          expect(GovukError).to receive(:notify)
            .with(Etl::Edition::Content::Parser::InvalidSchemaError.new("Schema does not exist: "), extra: { base_path: "" })
          expect(subject.extract_content(document_type: "answer")).to be_nil
        end
      end

      describe "has an unknown schema_name but no base_path" do
        it "logs InvalidSchemaError with the schema_name" do
          json = { schema_name: "blah", links: {} }

          expect(GovukError).to receive(:notify)
            .with(Etl::Edition::Content::Parser::InvalidSchemaError.new("Schema does not exist: blah"), extra: { base_path: "" })

          result = subject.extract_content(json.deep_stringify_keys)
          expect(result).to be_nil
        end
      end

      describe "has an unknown schema_name and a base_path" do
        it "raises InvalidSchemaError with the schema and the base_path" do
          json = { base_path: "/unknown/base_path",
                   schema_name: "unknown",
                   links: {} }
          subject.extract_content(json.deep_stringify_keys)
          expect(GovukError).to receive(:notify)
            .with(Etl::Edition::Content::Parser::InvalidSchemaError.new("Schema does not exist: unknown"), extra: { base_path: "/unknown/base_path" })
          expect(subject.extract_content(json.deep_stringify_keys)).to be_nil
        end
      end
    end
  end
end
