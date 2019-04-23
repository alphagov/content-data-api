module Healthchecks
  class SidekiqRetrySize < GovukHealthcheck::SidekiqRetrySizeCheck
    def critical_threshold
      100
    end

    def warning_threshold
      1
    end
  end
end
