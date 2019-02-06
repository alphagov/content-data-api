require 'active_support/concern'

module Healthchecks::Concerns::TimeRange
  extend ActiveSupport::Concern

  included do
    def enabled?
      healthchecks_enabled? && within_time_range?
    end

  private

    def adition_of_metric_values
      Facts::Metric.for_yesterday.sum(:pviews)
    end

    def healthchecks_enabled?
      ENV['ETL_HEALTHCHECK_ENABLED'] == '1'
    end

    def within_time_range?
      time = Time.zone.now

      time.hour >= Integer(ENV['ETL_HEALTHCHECK_ENABLED_FROM_HOUR'])
    end
  end
end
