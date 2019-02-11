require 'active_support/concern'

module Healthchecks::Concerns::Deactivable
  extend ActiveSupport::Concern

  included do
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
  end
end
