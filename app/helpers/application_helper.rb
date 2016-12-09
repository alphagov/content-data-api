module ApplicationHelper
  def order_link(heading, content_item_attribute)
    link_to heading, organisation_content_items_path(
      organisation_id: @organisation.id,
      sort: content_item_attribute,
      order: params.present? && params[:order] == "asc" ? :desc : :asc
    )
  end
end
