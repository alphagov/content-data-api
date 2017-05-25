class Search
  class Query
    attr_accessor :filters

    def initialize
      self.filters = {}
    end

    def filter_by(link_type:, target_content_ids:)
      if filters.key?(link_type)
        raise DuplicateFilterError, "already filtered by #{link_type}"
      end

      filters[link_type] = [target_content_ids].flatten
    end

    class ::DuplicateFilterError < StandardError; end
  end
end
