module Audits
  class AllocationsController < BaseController
    before_action :set_default_parameters, only: :index
    before_action :set_batch_values, only: %w(destroy create), if: -> { batch_size > content_ids.size }

    decorates_assigned :content_items

    def index
      @my_content_items_count = FindContent.my_content(current_user.uid).count
      @content_items = FindContent.paged(params_to_filter)
    end

    def create
      allocation = AllocateContent.call(user_uid: user_uid, content_ids: content_ids)

      if allocation.success?
        redirect_to redirect_url, notice: allocation.message
      else
        redirect_to redirect_url, alert: allocation.message
      end
    end

    def destroy
      unallocation = UnallocateContent.call(content_ids: content_ids)

      if unallocation.success?
        redirect_to redirect_url, notice: unallocation.message
      else
        redirect_to redirect_url, alert: unallocation.message
      end
    end

  private

    def set_default_parameters
      params[:allocated_to] ||= :no_one
      params[:audit_status] ||= Audits::Audit::NON_AUDITED
      params[:organisations] ||= [current_user.organisation_content_id]
      params[:primary] = 'true' unless params.key?(:primary)
    end

    def user_uid
      params.fetch(:allocate_to)
    end

    def set_batch_values
      params[:content_ids] = FindContent
                               .batch(
                                 params_to_filter,
                                 batch_size: batch_size,
                                 from_page: params_to_filter.page,
                               ).pluck(:content_id)
    end

    def batch_size
      params[:batch_size].to_i
    end

    def content_ids
      params.fetch(:content_ids, [])
    end

    def redirect_params
      params.permit(
        :allocate_to,
        :batch_size,
        :allocated_to,
        :audit_status,
        :content_ids,
        :document_type,
        :primary,
        :user_uid,
        organisations: [],
      )
    end

    def redirect_url
      audits_allocations_url(redirect_params)
    end
  end
end
