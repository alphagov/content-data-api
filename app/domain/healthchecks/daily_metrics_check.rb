module Healthchecks
  class DailyMetricsCheck
    include Concerns::Deactivable

    def name
      :daily_metrics
    end

    def status
      metrics.any? ? :ok : :critical
    end

    def message
      "ETL :: no daily metrics for day before yesterday" if status == :critical
    end

  private

    def metrics
      @metrics ||= Facts::Metric.where(dimensions_date_id: Time.zone.today - 2)
    end
  end
end
