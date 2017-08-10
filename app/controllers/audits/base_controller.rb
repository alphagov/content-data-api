module Audits
  class BaseController < ApplicationController
    layout "audits"
    helper_method :filter_params, :primary_org_only?

    def build_filter
      Filter.new(
        theme_id: params[:theme],
        page: params[:page],
        organisations: params[:organisations],
        document_type: params[:document_type],
        audit_status: params[:audit_status],
        primary_org_only: primary_org_only?,
        allocated_to: params[:allocated_to],
      )
    end

  private

    def filter_params
      request
        .query_parameters
        .deep_symbolize_keys
    end

    def primary_org_only?
      params[:primary].blank? || params[:primary] == "true"
    end
  end
end
