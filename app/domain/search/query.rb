class Search
  class Query
    attr_accessor :filters, :per_page, :page, :sort

    def initialize
      self.filters = []
      self.page = 1
      self.per_page = 25
      self.sort = :page_views_desc
    end

    def audit_status=(identifier)
      if identifier.present?
        filter = AuditFilter.find(identifier.to_sym)
        filters.push(filter)
      else
        filters.delete_if { |f| f.is_a?(AuditFilter) }
      end
    end

    def filter_by(link_type, source_ids, target_ids)
      filter = LinkFilter.new(
        link_type: link_type,
        source_ids: source_ids,
        target_ids: target_ids,
      )

      raise_if_already_filtered_by_link_type(filter)
      raise_if_mixing_source_and_target(filter)

      filters.push(filter)
    end

    def page=(value)
      @page = value.to_i
      @page = 1 if @page <= 0
    end

    def per_page=(value)
      @per_page = value.to_i
      @per_page = 100 if @per_page > 100
    end

    def sort=(identifier)
      @sort = Sort.find(identifier)
    end

  private

    def raise_if_already_filtered_by_link_type(filter)
      if link_filters.any? { |f| f.link_type == filter.link_type }
        raise FilterError, "duplicate filter for #{filter.link_type}"
      end
    end

    def raise_if_mixing_source_and_target(filter)
      if link_filters.any? { |f| f.by_source? != filter.by_source? }
        raise FilterError, "attempting to filter by source and target"
      end
    end

    def link_filters
      filters.select { |f| f.is_a?(LinkFilter) }
    end

    class ::FilterError < StandardError; end
  end
end
