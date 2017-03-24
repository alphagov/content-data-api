class ContentItemsDecorator < Draper::CollectionDecorator
  delegate :current_page, :total_pages, :limit_value, :entry_name, :total_count, :offset_value, :last_page?

  def header(filters = {})
    organisation = filters[:organisation]
    taxonomy = filters[:taxonomy]

    if organisation.present? && taxonomy.present?
      "#{organisation.title} + #{taxonomy.title}"
    elsif organisation.present?
      organisation.title
    elsif taxonomy.present?
      taxonomy.title
    else
      "GOV.UK"
    end
  end
end
