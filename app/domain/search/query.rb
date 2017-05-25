class Search
  class Query
    attr_accessor :filters

    def initialize
      self.filters = []
    end

    def filter_by(link_type:, source_ids:, target_ids:)
      filter = Filter.new(
        link_type: link_type,
        source_ids: source_ids,
        target_ids: target_ids,
      )

      raise_if_already_filtered_by_link_type(filter)
      raise_if_mixing_source_and_target(filter)

      filters.push(filter)
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

    class Filter
      attr_accessor :link_type, :source_ids, :target_ids

      def initialize(link_type:, source_ids:, target_ids:)
        self.link_type = link_type
        self.source_ids = [source_ids].flatten.compact
        self.target_ids = [target_ids].flatten.compact

        if source_ids.present? && target_ids.present?
          raise FilterError, "must filter by source or target"
        end
      end

      def by_source?
        source_ids.present?
      end
    end

    class ::FilterError < StandardError; end
  end
end
