RSpec.describe Item::Content::Parser do
  subject { described_class.instance }

  it "handles schemas that does not have useful content" do
    no_content_schemas = %w[
      coming_soon
      completed_transaction
      external_content
      generic
      homepage
      person
      placeholder_corporate_information_page
      placehold_worldwide_organisation
      placeholder_person
      placeholder
      policy
      special_route
      redirect
      vanish
    ]
    no_content_schemas.each do |schema|
      json = build_raw_json(schema_name: schema, body: "<p>Body for #{schema}</p>")
      expect(subject.extract_content(json.deep_stringify_keys)).to be_nil, "schema: '#{schema}' should return nil"
    end
  end

  def build_raw_json(body:, schema_name:)
    {
      schema_name: schema_name,
      details: {
        body: body
      }
    }
  end
end
