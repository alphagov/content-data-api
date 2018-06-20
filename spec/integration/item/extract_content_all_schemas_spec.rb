RSpec.describe 'Process parser', type: :integration do
  context 'with a list of content schemas' do
    schemas = GovukSchemas::Schema.all(schema_type: "notification")
    schemas.each do |schema, value|
      schema_name = schema.split('/')[-3]
      it "extracts the content for: #{schema_name}" do
        sample = GovukSchemas::RandomExample.new(schema: value).payload
        expect(Item::Content::Parser.extract_content(sample)).to be_a(String).or eq(nil)
      end
    end
  end
end
