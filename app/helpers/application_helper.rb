module ApplicationHelper
  def order_link(heading, content_item_attribute, order)
    link_to heading, organisation_content_items_path(
      organisation_id: @organisation,
      sort: content_item_attribute,
      order: order.present? && order == "asc" ? :desc : :asc
    )
  end
end
