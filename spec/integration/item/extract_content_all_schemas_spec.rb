require "support/schemas_iterator"

RSpec.describe "Process parser", type: :integration do
  include SchemasIterator

  context "with a list of content schemas" do
    SchemasIterator.each_schema do |schema_name, schema|
      it "extracts the content for: #{schema_name}" do
        payload = SchemasIterator.payload_for(schema_name, schema)
        expect(Etl::Edition::Content::Parser.extract_content(payload)).to be_a(String).or eq(nil)
      end
    end
  end
end
