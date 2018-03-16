require 'active_support/concern'

module Concerns::Traceable
  extend ActiveSupport::Concern

  included do
    def time(process:)
      raise ArgumentError "No block was given to Traceable#time" unless block_given?
      started = Time.now
      logger.info "Process: '#{process}' started at #{started}"
      yield
      ended = Time.now
      logger.info "Process: '#{process}' ended at #{ended}, duration: #{ended - started}"
    rescue StandardError => ex
      logger.error(ex.message)
      logger.error(ex.backtrace.inspect)
      raise ex
    end

    def log(message:)
      logger.info message
    end
  end
end
