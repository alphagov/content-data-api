require 'active_support/concern'

module Concerns::TraceAndRecoverable
  extend ActiveSupport::Concern
  include Concerns::Traceable

  included do
    def time_and_trap(process:, &block)
      raise ArgumentError "No block was given to TraceAndRecoverable#time_and_trap" unless block_given?

      begin
        time(process: process, &block)
      rescue StandardError => e
        GovukError.notify(e)
      end
    end
  end
end
