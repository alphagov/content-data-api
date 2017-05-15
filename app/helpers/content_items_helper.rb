module ContentItemsHelper
  def advanced_filter_enabled?
    params[:taxonomy_content_id].present?
  end
end
