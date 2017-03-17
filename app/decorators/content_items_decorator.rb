class ContentItemsDecorator < Draper::CollectionDecorator
  delegate :current_page, :total_pages, :limit_value, :entry_name, :total_count, :offset_value, :last_page?

  def header
    if slug.present? && taxonomy.present?
      "#{Organisation.find_by(slug: slug).title} + #{taxonomy}"
    elsif slug.present?
      Organisation.find_by(slug: slug).title
    elsif taxonomy.present?
      taxonomy
    else
      "GOV.UK"
    end
  end

private

  def slug
    helpers.params[:organisation_slug]
  end

  def taxonomy
    helpers.params[:taxonomy]
  end
end
