module OrganisationsHelper
  def stringify_organisations(organisations)
    names = organisations.collect do |organisation|
      link_to(organisation.title, organisation_content_items_path(organisation_slug: organisation.slug))
    end

    names.join(', ').html_safe
  end
end
