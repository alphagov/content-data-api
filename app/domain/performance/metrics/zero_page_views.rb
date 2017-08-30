module Performance::Metrics
  class ZeroPageViews
    attr_accessor :scope

    def initialize(scope)
      @scope = scope
    end

    def run
      { zero_page_views: { value: scope.where(one_month_page_views: 0).count } }
    end
  end
end
