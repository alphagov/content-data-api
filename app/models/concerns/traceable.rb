require 'active_support/concern'

module Concerns::Traceable
  extend ActiveSupport::Concern

  include ActionView::Helpers::DateHelper
  included do
    def time(process:)
      raise ArgumentError "No block was given to Traceable#time" unless block_given?
      started = Time.now
      logger.info "Process: '#{process}' started at #{started.to_formatted_s(:db)}"
      yield
      ended = Time.now
      duration = format_duration(started, ended)
      logger.info "Process: '#{process}' ended at #{ended.to_formatted_s(:db)}, duration: #{duration}"
    rescue StandardError => ex
      logger.error(ex.message)
      logger.error(ex.backtrace.inspect)
      raise ex
    end

    def log(process:, message:)
      logger.info "Process: '#{process}' : #{message}"
    end

  private

    def format_duration(starts, ends)
      distance_of_time_in_words(starts, ends, include_seconds: true)
    end
  end
end
