class Importers::AllContentItems
  attr_accessor :content_items_service

  def initialize
    @content_items_service = ItemsService.new
  end

  def run
    content_items = content_items_service.fetch_all_with_default_locale_only

    content_items.each do |content_item|
      ImportItemJob.perform_async(content_item[:content_id], content_item[:locale], content_item[:user_facing_version])
    end
  end
end
