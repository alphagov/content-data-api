module Performance::Metrics
  class TotalPages
    attr_reader :scope

    def initialize(scope)
      @scope = scope
    end

    def run
      { total_pages: { value: scope.count } }
    end
  end
end
