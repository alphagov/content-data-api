module Audits
  class BaseController < ApplicationController
    layout "audits"
    helper_method :filter_params, :primary_org_only?

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
