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
      healthchecks_enabled? && within_time_range?
    end

  private

    def healthchecks_enabled?
      ENV['ETL_HEALTHCHECK_ENABLED'] == '1'
    end

    def within_time_range?
      time = Time.zone.now

      time.hour >= Integer(ENV['ETL_HEALTHCHECK_ENABLED_FROM_HOUR'])
    end

    def metrics
      @metrics ||= Facts::Metric.where(dimensions_date_id: Date.yesterday)
    end
  end
end
