class Etl::Edition::Content::Parsers::NoContent
  def parse(_json)
    nil
  end

  def schemas
    %w[
      coronavirus_landing_page
      coming_soon
      completed_transaction
      external_content
      facet
      facet_group
      facet_value
      generic
      government
      homepage
      knowledge_alpha
      ministers_index
      organisations_homepage
      person
      placeholder_corporate_information_page
      placeholder_ministerial_role
      placeholder_organisation
      placeholder_policy_area
      placeholder_topical_event
      placeholder_world_location
      placeholder_worldwide_organisation
      placeholder_person
      placeholder
      policy
      redirect
      role
      role_appointment
      special_route
      topic
      world_location
      vanish
    ]
  end
end
