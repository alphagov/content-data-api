require "active_support/concern"

module TraceAndRecoverable
  extend ActiveSupport::Concern
  include Traceable

  included do
    def time_and_trap(process:, &block)
      raise ArgumentError "No block was given to TraceAndRecoverable#time_and_trap" unless block_given?

      begin
        time(process: process, &block)

        true
      rescue StandardError => e
        GovukError.notify(e)

        false
      end
    end

    def trap
      raise ArgumentError "No block was given to TraceAndRecoverable#trap" unless block_given?

      begin
        yield

        true
      rescue StandardError => e
        GovukError.notify(e)

        false
      end
    end
  end
end
