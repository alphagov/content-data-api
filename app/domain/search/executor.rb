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
      query.filters.each { |f| self.scope = f.apply(scope) }
      self.scope = query.sort.apply(scope)
      self.scope = scope.page(query.page).per(query.per_page)

      Result.new(scope)
    end
  end
end
