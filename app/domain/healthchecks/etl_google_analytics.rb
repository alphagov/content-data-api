module Healthchecks
  class EtlGoogleAnalytics
    include Concerns::TimeRange

    def name
      :etl_google_analytics_pviews
    end

    def status
      if adition_of_metric_values.positive?
        :ok
      else
        :critical
      end
    end

  private

    def adition_of_metric_values
      Facts::Metric.for_yesterday.sum(:pviews)
    end
  end
end
