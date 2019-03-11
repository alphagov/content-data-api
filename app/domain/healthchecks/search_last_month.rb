module Healthchecks
  class SearchLastMonth
    include Concerns::Deactivable

    def name
      :search_last_month
    end

    def status
      searches.positive? ? :ok : :critical
    end

    def message
      "ETL :: no last month aggregations for searches updated from yesterday" if status == :critical
    end

  private

    def searches
      @searches ||= Aggregations::SearchLastMonth.where(updated_at: Date.today).count
    end
  end
end
