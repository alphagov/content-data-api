module Healthchecks
  class EtlGoogleAnalytics
    include ActiveModel::Model
    include Concerns::Deactivable

    attr_accessor :metric

    def self.build(metric)
      new(metric: metric)
    end

    def name
      "etl_google_analytics_#{metric}".to_sym
    end

    def status
      if addition_of_metric_values.positive?
        :ok
      else
        :critical
      end
    end

    def message
      "ETL :: no #{metric} for yesterday" if status == :critical
    end

  private

    def addition_of_metric_values
      Facts::Metric.for_yesterday.where("#{metric} > 0").count
    end
  end
end
