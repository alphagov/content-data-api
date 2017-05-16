module Metrics
  class PagesNotUpdated
    attr_accessor :content_items

    def initialize(content_items)
      @content_items = content_items
    end

    def run
      { pages_not_updated: { value: content_items.where("public_updated_at < ?", 6.months.ago).count } }
    end
  end
end
