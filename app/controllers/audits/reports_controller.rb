module Audits
  class ReportsController < BaseController
    def show
      @monitor = ::Audits::Monitor.new(filter)
    end
  end
end
