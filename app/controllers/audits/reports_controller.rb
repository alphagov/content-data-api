module Audits
  class ReportsController < BaseController
    def show
      @content_query ||= Content::Query.new
                           .page(params[:page])
                           .organisations(params[:organisations], primary_org_only?)
                           .document_type(params[:document_type])
                           .theme(params[:theme])

      @content_items = FindContent.call(
        params[:theme],
        page: params[:page],
        organisations: params[:organisations],
        document_type: params[:document_type],
        primary_org_only: primary_org_only?,
      ).decorate
    end

  private

    def audit_status_filter_enabled?
      action_name != "report"
    end
  end
end
