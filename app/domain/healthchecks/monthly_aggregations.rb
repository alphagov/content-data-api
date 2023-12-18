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
      "ETL :: no monthly aggregations of metrics for day before yesterday" if status == :critical
    end

  private

    def aggregations
      @aggregations ||= Aggregations::MonthlyMetric.where("created_at > ?", Time.zone.today).count
    end
  end
end
