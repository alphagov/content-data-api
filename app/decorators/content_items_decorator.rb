class ContentItemsDecorator < Draper::CollectionDecorator
  delegate :current_page, :total_pages, :limit_value, :entry_name, :total_count, :offset_value, :last_page?

  def header(organisation)
    if organisation.present?
      organisation.title
    else
      'GOV.UK'
    end
  end
end
