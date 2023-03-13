module Healthchecks
  class SearchAggregations
    include ActiveModel::Model
    include Concerns::Deactivable

    attr_accessor :range

    def self.build(range)
      new(range:)
    end

    def name
      "search_#{range}".to_sym
    end

    def status
      searches.positive? ? :ok : :critical
    end

    def message
      "ETL :: no #{range.to_s.humanize} searches updated from yesterday" if status == :critical
    end

  private

    def klass_name
      "Aggregations::Search#{range.to_s.camelize}".constantize
    end

    def searches
      @searches ||= klass_name.where(updated_at: Time.zone.today).count
    end
  end
end
