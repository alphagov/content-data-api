module ContentItemsHelper
  def content_items_header
    if @organisation.present?
      @organisation.title
    else
      'GOV.UK'
    end
  end
end
