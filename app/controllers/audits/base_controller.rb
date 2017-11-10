module Audits
  class BaseController < ApplicationController
    layout "audits"
    helper_method :params_to_filter, :filter_params

    def params_to_filter
      options = {
        allocated_to: params[:allocated_to],
        audit_status: params[:audit_status],
        document_type: params[:document_type],
        page: params[:page],
        sort: Sort.column(params[:sort_by]),
        sort_direction: Sort.direction(params[:sort_by]),
        primary_org_only: params[:primary] == 'true',
        organisations: params.fetch(:organisations, []).flatten.reject(&:blank?),
        title: params[:query],
      }

      options.delete_if { |_, v| v.blank? }

      Filter.new(options)
    end

    def filter_params
      options = {
        allocated_to: params[:allocated_to],
        audit_status: params[:audit_status],
        document_type: params[:document_type],
        organisations: params.fetch(:organisations, []).flatten.reject(&:blank?),
        primary: params[:primary],
        query: params[:title],
        sort_by: params[:sort_by],
        title: params[:query],
      }
      options.delete_if { |_, v| v.blank? }

      options
    end
  end
end
