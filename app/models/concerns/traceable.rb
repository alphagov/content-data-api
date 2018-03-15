require 'active_support/concern'

module Concerns::Traceable
  extend ActiveSupport::Concern

  included do
    def time(process:)
      started = Time.now
      logger.info "Process: '#{process}' started at #{started}"
      yield
      ended = Time.now
      logger.info "Process: '#{process}' ended at #{ended}, duration: #{ended - started}"
    end
  end
end
