module SchemasIterator
  def self.each_schema
    all_schemas.each do |schema_name, value|
      schema_name = schema_name.split("/")[-3]
      yield schema_name, value
    end
  end

  def self.payload_for(schema_name, schema)
    all_payloads[schema_name] ||= GovukSchemas::RandomExample.new(schema:).payload
  end

  def self.all_payloads
    @all_payloads ||= {}
  end

  def self.all_schemas
    @all_schemas ||= GovukSchemas::Schema.all(schema_type: "notification")
  end
end
