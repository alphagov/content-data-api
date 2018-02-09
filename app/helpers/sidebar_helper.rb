module SidebarHelper
  def stringify_filter
    content_ids = filter_params
                    .values_at(:organisations, :taxons)
                    .compact
                    .delete_if(&:empty?)

    if content_ids.empty?
      "GOV.UK"
    else
      Item.where(content_id: content_ids).map(&:title).join(" + ")
    end
  end
end
