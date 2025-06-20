class Etl::Edition::Content::Parsers::NoContent
  def parse(_json)
    nil
  end

  def schemas
    %w[
      coming_soon
      completed_transaction
      content_block_contact
      content_block_pension
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
  end
end
