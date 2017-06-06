class ContentItemsDecorator < Draper::CollectionDecorator
  delegate(
    :current_page,
    :total_pages,
    :limit_value,
    :entry_name,
    :total_count,
    :offset_value,
    :last_page?,
    :next_item,
  )

  def header(filters = {})
    organisation = filters[:organisation]
    taxon = filters[:taxon]

    if organisation.present? && taxon.present?
      "#{organisation.title} + #{taxon.title}"
    elsif organisation.present?
      organisation.title
    elsif taxon.present?
      taxon.title
    else
      "GOV.UK"
    end
  end
end
