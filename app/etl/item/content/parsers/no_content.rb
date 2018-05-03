class Item::Content::Parsers::NoContent
  def parse(_json)
    nil
  end

  def schemas
    %w[
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
  end
end
