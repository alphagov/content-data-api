class ContentItemsDecorator < Draper::CollectionDecorator
  delegate :current_page, :total_pages, :limit_value, :entry_name, :total_count, :offset_value, :last_page?

  def header
    if organisation_slug.present? && taxonomy_content_id.present?
      "#{Organisation.find_by(slug: organisation_slug).title} + #{Taxonomy.find_by(content_id: taxonomy_content_id).title}"
    elsif organisation_slug.present?
      Organisation.find_by(slug: organisation_slug).title
    elsif taxonomy_content_id.present?
      Taxonomy.find_by(content_id: taxonomy_content_id).title
    else
      "GOV.UK"
    end
  end

private

  def organisation_slug
    helpers.params[:organisation_slug]
  end

  def taxonomy_content_id
    helpers.params[:taxonomy_content_id]
  end
end
