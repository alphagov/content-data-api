class Etl::Edition::Content::Parsers::NoContent
  def parse(_json)
    nil
  end

  def schemas
    %w[
      coming_soon
      completed_transaction
      coronavirus_landing_page
      embassies_index
      external_content
      facet
      facet_group
      facet_value
      field_of_operation
      generic
      government
      historic_appointments
      historic_appointment
      homepage
      how_government_works
      knowledge_alpha
      landing_page
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
      special_route
      topic
      vanish
      world_location
    ]
  end
end
