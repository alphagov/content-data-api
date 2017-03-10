class ContentItemsDecorator < Draper::CollectionDecorator
  delegate :current_page, :total_pages, :limit_value, :entry_name, :total_count, :offset_value, :last_page?

  def header
    slug = helpers.params[:organisation_slug]
    if slug
      Organisation.find_by(slug: slug).title
    else
      'GOV.UK'
    end
  end
end
