module Healthchecks
  class SearchLastThirtyDays
    include Concerns::Deactivable

    def name
      :search_last_thirty_days
    end

    def status
      searches.positive? ? :ok : :critical
    end

    def message
      "ETL :: no last 30 days aggregations for searches updated from yesterday" if status == :critical
    end

  private

    def searches
      @searches ||= Aggregations::SearchLastThirtyDays.where(updated_at: Date.today).count
    end
  end
end
