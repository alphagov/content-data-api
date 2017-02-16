module OrganisationsHelper
  def stringify_organisations(organisations, options = {})
    organisation_titles = if options[:linkify]
                            organisations.collect do |organisation|
                              link_to(organisation.title, organisation_content_items_path(organisation_slug: organisation.slug))
                            end
                          else
                            organisations.collect(&:title)
                          end

    organisation_titles.join(', ').html_safe
  end
end
