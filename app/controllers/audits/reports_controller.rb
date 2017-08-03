module Audits
  class ReportsController < ApplicationController
    layout "audits"

    helper_method :filter_params, :primary_org_only?

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

    def primary_org_only?
      params[:primary].blank? || params[:primary] == "true"
    end

    def audit_status_filter_enabled?
      action_name != "report"
    end

    def filter_params
      request
        .query_parameters
        .deep_symbolize_keys
    end
  end
end
