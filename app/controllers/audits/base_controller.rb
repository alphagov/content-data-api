module Audits
  class BaseController < ApplicationController
    layout "audits"
    helper_method :filter, :filter_params, :primary_org_only?

    def filter(override = {})
      options = default_filter
        .merge(query_string_filter)
        .merge(override)

      Filter.new(options)
    end

  private

    def query_string_filter
      options = {
        allocated_to: params[:allocated_to],
        audit_status: params[:audit_status],
        document_type: params[:document_type],
        organisations: organisations,
        page: params[:page],
        primary_org_only: primary_org_only?,
        sort_by: params[:sort_by],
        title: params[:query],
      }

      options.delete_if do |_, v|
        v == "" || v.nil?
      end
    end

    def default_filter
      {}
    end

    def filter_params
      request
        .query_parameters
        .deep_symbolize_keys
    end

    def primary_org_only?
      params[:primary].blank? || params[:primary] == "true"
    end

    def organisations
      params
        .fetch(:organisations, [])
        .flatten
        .reject(&:blank?)
    end
  end
end
