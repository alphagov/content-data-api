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
        nested = Link.where(link_type: filter.link_type)

        if filter.by_source?
          nested = nested.where(source_content_id: filter.source_ids)
          nested = nested.select("target_content_id as content_id")
        else
          nested = nested.where(target_content_id: filter.target_ids)
          nested = nested.select("source_content_id as content_id")
        end

        self.scope = scope.where(content_id: nested)
      end
    end

    def apply_sort
      if query.sort == :page_views_desc
        self.scope = scope.order("six_months_page_views desc")
      end
    end

    def apply_pagination
      if query.per_page && query.page
        self.scope = scope.page(query.page).per(query.per_page)
      end
    end
  end
end
