RSpec.describe Etl::Edition::Content::Parser do
  subject { described_class }

  before do
    allow(GovukError).to receive(:notify)
  end

  it "handles schemas that does not have useful content" do
    no_content_schemas = %w[
      coming_soon
      completed_transaction
      content_block_contact
      content_block_pension
      content_block_postal_address
      coronavirus_landing_page
      embassies_index
      external_content
      facet
      facet_group
      facet_value
      field_of_operation
      generic
      government
      historic_appointment
      historic_appointments
      homepage
      how_government_works
      knowledge_alpha
      landing_page
      link_collection
      ministers_index
      organisations_homepage
      person
      placeholder
      placeholder_corporate_information_page
      placeholder_ministerial_role
      placeholder_organisation
      placeholder_person
      placeholder_policy_area
      placeholder_topical_event
      placeholder_world_location
      placeholder_worldwide_organisation
      policy
      redirect
      role
      role_appointment
      smart_answer
      special_route
      substitute
      topic
      vanish
      world_index
      world_location
    ]
    no_content_schemas.each do |schema|
      json = build_raw_json(schema_name: schema, body: "<p>Body for #{schema}</p>")
      expect(subject.extract_content(json.deep_stringify_keys)).to be_nil, "schema: '#{schema}' should return nil"
    end
    expect(GovukError).not_to have_received(:notify)
  end

  def build_raw_json(body:, schema_name:)
    {
      schema_name:,
      details: {
        body:,
      },
    }
  end
end
