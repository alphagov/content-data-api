require 'support/schemas_iterator'

RSpec.describe 'Process parser', type: :integration do
  include SchemasIterator

  context 'with a list of content schemas' do
    SchemasIterator.each_schema do |schema_name, schema|
      it "extracts the content for: #{schema_name}" do
        sample = GovukSchemas::RandomExample.new(schema: schema).payload
        expect(Item::Content::Parser.extract_content(sample)).to be_a(String).or eq(nil)
      end
    end
  end
end
