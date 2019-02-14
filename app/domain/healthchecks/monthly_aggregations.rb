module Healthchecks
  class MonthlyAggregations
    include Concerns::Deactivable

    def name
      :aggregations
    end

    def status
      aggregations.positive? ? :ok : :critical
    end

    def message
      "ETL :: no aggregations of metrics for yesterday" if status == :critical
    end

  private

    def aggregations
      @aggregations ||= Aggregations::MonthlyMetric.where(created_at: Date.today).count
    end
  end
end
