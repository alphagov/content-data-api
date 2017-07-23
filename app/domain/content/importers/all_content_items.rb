module Content
  class Importers::AllContentItems
    attr_accessor :content_items_service

    def initialize
      @content_items_service = ContentItemsService.new
    end

    def run
      content_ids = content_items_service.content_ids

      content_ids.each do |content_id|
        ImportContentItemJob.perform_later(content_id)
      end
    end
  end
end
