module Audits
  class ReportsController < BaseController
    def show
      @monitor = ::Audits::Monitor.new(filter)
    end

  private

    def default_filter
      {
        allocated_to: current_user.uid,
        audit_status: Audit::ALL,
      }
    end
  end
end
