module Healthchecks
  class DailyMetricsCheck
    def name
      :daily_metrics
    end

    def status
      metrics.any? ? :ok : :critical
    end

    def message
      "ETL :: no daily metrics for yesterday"
    end

    def enabled?
      time = Time.zone.now

      time.hour >= 9 && time.min > 30
    end

    private

    def metrics
      @metrics ||= Facts::Metric.where(dimensions_date_id: Date.yesterday)
    end
  end
end
