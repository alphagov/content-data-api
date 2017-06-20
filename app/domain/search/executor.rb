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
      build_link_type_options!
      build_document_type_options!

      apply_filters!
      apply_sort!
      paginate!

      Result.new(scope, filter_options)
    end

  private

    def build_link_type_options!
      Search.all_link_types.each do |link_type|
        other_filters = query.filters.reject { |f| matches?(f, LinkFilter, link_type) }
        scope_to_count = apply_filters(other_filters, self.scope)

        filter_options[link_type] = ContentItem.targets_of(
          link_type: link_type,
          scope_to_count: scope_to_count,
        )
      end
    end

    def build_document_type_options!
      other_filters = query.filters.reject { |f| matches?(f, DocumentTypeFilter) }
      scope_to_count = apply_filters(other_filters, self.scope)

      filter_options[:document_type] = scope_to_count.document_type_counts
    end

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
      self.scope = query.sort.apply(scope)
    end

    def paginate!
      self.scope = scope.page(query.page).per(query.per_page)
    end
  end
end
