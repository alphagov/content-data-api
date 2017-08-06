module Audits
  class ReportsController < BaseController
    def show
      @monitor = ::Audits::Monitor.new(build_filter)
    end
  end
end
