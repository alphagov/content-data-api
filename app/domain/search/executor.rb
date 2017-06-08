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
      build_filter_options

      apply_filters
      apply_sort
      paginate

      Result.new(scope, filter_options)
    end

  private

    def build_filter_options
      Search::LINK_TYPE_FILTERS.each do |link_type|
        filter_options.merge!(
          link_type => ContentItem.targets_of(
            link_type: link_type,
            scope_to_count: apply_filters_except_for(link_type),
          )
        )
      end
    end

    def apply_filters_except_for(link_type)
      query.filters.inject(self.scope) do |scope, filter|
        if filter.respond_to?(:link_type) && filter.link_type == link_type
          scope
        else
          filter.apply(scope)
        end
      end
    end

    def apply_filters
      query.filters.each { |f| self.scope = f.apply(scope) }
    end

    def apply_sort
      self.scope = query.sort.apply(scope)
    end

    def paginate
      self.scope = scope.page(query.page).per(query.per_page)
    end
  end
end
