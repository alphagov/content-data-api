module ContentItemsHelper
  def advanced_filter_enabled?
    params[:taxon_content_id].present?
  end
end
