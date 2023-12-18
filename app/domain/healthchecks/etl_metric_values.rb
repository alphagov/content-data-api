module Healthchecks
  class EtlMetricValues
    include ActiveModel::Model
    include Concerns::Deactivable

    attr_accessor :metric

    def self.build(metric)
      new(metric:)
    end

    def name
      "etl_metric_values_#{metric}".to_sym
    end

    def status
      if number_of_metric_values.positive?
        :ok
      else
        :critical
      end
    end

    def message
      "ETL :: no #{metric} for day before yesterday" if status == :critical
    end

  private

    def number_of_metric_values
      Facts::Metric.for_2_days_ago.where("#{metric} > 0").count
    end
  end
end
