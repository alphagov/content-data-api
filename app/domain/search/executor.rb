class Search
  class Executor
    def self.execute(query)
      new(query).execute
    end

    attr_accessor :query, :scope, :filter_options

    def initialize(query)
      self.query = query
      self.scope = ContentItem.all
      self.filter_options = {}
    end

    def execute
      apply_filters!
      apply_sort!
      paginate!

      Result.new(scope)
    end

  private

    def matches?(filter, type, link_type = nil)
      filter.is_a?(type) && (link_type.nil? || filter.link_type == link_type)
    end

    def apply_filters!
      self.scope = apply_filters(query.filters, self.scope)
    end

    def apply_filters(filters, scope)
      filters.each { |f| scope = f.apply(scope) }
      scope
    end

    def apply_sort!
      self.scope = scope.order(
        query.sort => query.sort_direction,
        # Finally sort by base path (which is unique) to stabilise sort order
        :base_path => :asc,
      )
    end

    def paginate!
      self.scope = scope.page(query.page).per(query.per_page)
    end
  end
end
