RSpec.describe 'Process parser', type: :integration do
  let(:invalid_schema_list) {
    %w[
      topic
      world_location
    ]
  }

  context 'with a list of content schemas' do
    it 'extracts the content valid schemas' do
      schemas = valid_schemas
      schemas.each do |schema|
        expect(Item::Content::Parser.extract_content(schema)).to be_a(String).or eq(nil)
      end
    end

    it 'returns nil for unused schemas' do
      schemas = invalid_schemas
      schemas.each do |schema|
        expect(Item::Content::Parser.extract_content(schema)).to be_nil
      end
    end
  end

  def get_schema_collection
    schemas = GovukSchemas::Schema.all(schema_type: "notification")
    schemas.values
  end

  def invalid_schemas
    schemas = get_schema_collection

    schemas.each do |schema|
      random_example = GovukSchemas::RandomExample.new(schema: schema).payload
      schemas.delete(schema) unless invalid_schema_list.include?(random_example.dig("schema_name"))
    end
    schemas
  end

  def valid_schemas
    schemas = get_schema_collection

    schemas.each do |schema|
      random_example = GovukSchemas::RandomExample.new(schema: schema).payload
      schemas.delete(schema) if invalid_schema_list.include?(random_example.dig("schema_name"))
    end
    schemas
  end
end
