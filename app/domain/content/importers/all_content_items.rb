module Content
  class Importers::AllContentItems
    attr_accessor :content_items_service

    def initialize
      @content_items_service = Content::ItemsService.new
    end

    def run
      content_items = content_items_service.fetch_all_with_default_locale_only

      content_items.each do |content_item|
        ImportContentItemJob.perform_later(content_item[:content_id], content_item[:locale])
      end
    end
  end
end
