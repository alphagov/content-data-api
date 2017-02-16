module OrganisationsHelper
  def stringify_organisations(organisations)
    organisations.collect(&:title).join(', ').html_safe
  end
end
