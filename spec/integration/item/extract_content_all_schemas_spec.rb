RSpec.describe 'Process parser', type: :integration do
  context 'with a list of content schemas' do
    it 'extracts the content valid schemas' do
      schemas = GovukSchemas::Schema.all(schema_type: "notification").values

      schemas.each do |schema|
        sample = GovukSchemas::RandomExample.new(schema: schema).payload
        expect(Item::Content::Parser.extract_content(sample)).to be_a(String).or eq(nil)
      end
    end
  end

end
