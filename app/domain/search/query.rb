class Search
  class Query
    attr_accessor :filters, :per_page, :page, :sort

    def initialize
      self.filters = []
      self.page = 1
      self.per_page = 25
      self.sort = :page_views_desc
    end

    def filter_by(filter)
      if filter.is_a?(LinkFilter)
        raise_if_already_filtered_by_link_type(filter)
        raise_if_mixing_source_and_target(filter)
      end

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

  private

    def raise_if_already_filtered_by_link_type(filter)
      if filters.any? { |f| f.link_type == filter.link_type }
        raise FilterError, "duplicate filter for #{filter.link_type}"
      end
    end

    def raise_if_mixing_source_and_target(filter)
      if filters.any? { |f| f.by_source? != filter.by_source? }
        raise FilterError, "attempting to filter by source and target"
      end
    end

    class ::FilterError < StandardError; end
  end
end
