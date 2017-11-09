module Audits
  class BaseController < ApplicationController
    layout "audits"
    helper_method :filter, :filter_params

    def filter
      options = filter_from_non_blankable_query_parameters

      Filter.new(options)
    end

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

  private

    def filter_from_non_blankable_query_parameters
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
    end

    def filter_params
      Audits::SerializeFilterToQueryParameters
        .new(filter)
        .call
    end
  end
end
