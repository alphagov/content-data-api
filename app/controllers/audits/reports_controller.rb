module Audits
  class ReportsController < BaseController
    before_action :set_default_parameters, only: :show

    def show
      @monitor = ::Audits::Monitor.new(filter)
    end

  private

    def set_default_parameters
      params[:allocated_to] ||= current_user.uid
      params[:audit_status] ||= Audits::Audit::ALL
      params[:organisations] ||= [current_user.organisation_content_id]
      params[:primary] ||= 'true'
    end
  end
end
