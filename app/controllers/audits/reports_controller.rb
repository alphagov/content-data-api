module Audits
  class ReportsController < BaseController
    def show
      @default_filter = {
        allocated_to: current_user.uid,
        audit_status: Audits::Audit::ALL,
        organisations: [current_user.organisation_content_id],
        primary_org_only: true,
      }

      @monitor = ::Audits::Monitor.new(filter)
    end
  end
end
