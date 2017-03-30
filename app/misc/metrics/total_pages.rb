module Metrics
  class TotalPages
    attr_accessor :content_items

    def initialize(content_items)
      @content_items = content_items
    end

    def run
      { total_pages: { value: content_items.count } }
    end
  end
end
