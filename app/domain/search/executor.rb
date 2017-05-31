class Search
  class Executor
    def self.execute(query)
      new(query).execute
    end

    attr_accessor :query, :scope

    def initialize(query)
      self.query = query
      self.scope = ContentItem.all
    end

    def execute
      apply_filters
      apply_sort
      apply_pagination

      Result.new(scope)
    end

  private

    def apply_filters
      query.filters.each do |filter|
        self.scope = filter.apply(scope)
      end
    end

    def apply_sort
      if query.sort == :page_views_desc
        self.scope = scope.order("six_months_page_views desc")
      end
    end

    def apply_pagination
      self.scope = scope.page(query.page).per(query.per_page)
    end
  end
end
