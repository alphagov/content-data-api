module Healthchecks
  class DailyMetricsCheck
    def name
      :daily_metrics
    end

    def status
      metrics.any? ? :ok : :critical
    end

    def message
      "There are #{metrics.count} metrics for #{Date.yesterday}"
    end

  private

    def metrics
      @metrics ||= Facts::Metric.where(dimensions_date_id: Date.yesterday)
    end
  end
end
