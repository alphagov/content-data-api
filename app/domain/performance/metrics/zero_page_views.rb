module Performance::Metrics
  class ZeroPageViews
    attr_accessor :content_items

    def initialize(content_items)
      @content_items = content_items
    end

    def run
      { zero_page_views: { value: content_items.where("one_month_page_views = 0").count } }
    end
  end
end
