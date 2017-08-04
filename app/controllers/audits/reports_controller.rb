module Audits
  class ReportsController < BaseController
    def show
      @monitor = ::Audits::Monitor.new(
        params[:theme],
        organisations: params[:organisations],
        document_type: params[:document_type],
        primary_org_only: primary_org_only?,
      )
    end
  end
end
