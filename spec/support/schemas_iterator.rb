module SchemasIterator
  def self.each_schema
    schemas = GovukSchemas::Schema.all(schema_type: "notification")
    schemas.each do |schema, value|
      schema_name = schema.split('/')[-3]
      yield schema_name, value
    end
  end
end
