module Healthchecks
  class EtlGoogleAnalytics
    include ActiveModel::Model
    include Concerns::TimeRange

    attr_accessor :metric

    def self.build(metric)
      new(metric: metric)
    end

    def name
      "etl_google_analytics_#{metric}".to_sym
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
