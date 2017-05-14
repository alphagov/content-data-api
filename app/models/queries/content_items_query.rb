module Queries
  class ContentItemsQuery
    attr_accessor :query, :page

    def initialize(options)
      @page = options.delete :page
      @query = build_query(options)
    end

    def results
      query
    end

    def paginated_results
      query.page(page)
    end

  private

    def build_query(options = {})
      relation = ContentItem.all
      relation = filter_by_taxonomy(relation, options[:taxonomy])
      relation = filter_by_organisations(relation, options[:organisation])
      relation = filter_by_title(relation, options[:query])
      relation.order("#{options[:sort]} #{options[:order]}")
    end

    def filter_by_taxonomy(relation, taxonomy)
      return relation unless taxonomy
      relation.joins(:taxonomies).where('taxonomies.id = ?', taxonomy.id)
    end

    def filter_by_organisations(relation, organisation)
      return relation unless organisation
      relation.joins(:organisations).where('organisations.id = ?', organisation.id)
    end

    def filter_by_title(relation, query)
      return relation if query.blank?
      relation.where('content_items.title ilike ?', "%#{query}%")
    end
  end
end
