class ContentItemsDecorator < Draper::CollectionDecorator
  delegate :current_page, :total_pages, :limit_value, :entry_name, :total_count, :offset_value, :last_page?

  def header
    if organisation_slug.present? && taxonomy.present?
      "#{Organisation.find_by(slug: organisation_slug).title} + #{taxonomy}"
    elsif organisation_slug.present?
      Organisation.find_by(slug: organisation_slug).title
    elsif taxonomy.present?
      taxonomy
    else
      "GOV.UK"
    end
  end

private

  def organisation_slug
    helpers.params[:organisation_slug]
  end

  def taxonomy
    helpers.params[:taxonomy]
  end
end
