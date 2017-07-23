module Performance::Metrics
  class PagesNotUpdated
    attr_reader :scope

    def initialize(scope)
      @scope = scope
    end

    def run
      { pages_not_updated: { value: scope.where("public_updated_at < ?", 6.months.ago).count } }
    end
  end
end
