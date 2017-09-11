module Audits
  class BaseController < ApplicationController
    layout "audits"
    helper_method :filter_params, :primary_org_only?

    def build_filter
      Filter.new(
        allocated_to: params[:allocated_to],
        audit_status: params[:audit_status],
        current_user_id: current_user.uid,
        document_type: params[:document_type],
        organisations: params[:organisations],
        page: params[:page],
        primary_org_only: primary_org_only?,
        sort_by: params[:sort_by],
        theme_id: params[:theme],
        title: params[:query],
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
