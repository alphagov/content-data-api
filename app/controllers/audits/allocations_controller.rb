module Audits
  class AllocationsController < BaseController
    before_action :set_batch_value, only: %w(destroy create), if: -> { batch_size > content_ids.size }

    decorates_assigned :content_items

    def index
      @content_items = FindContent.paged(build_filter)
    end

    def create
      allocation = AllocateContent.call(user_uid: user_uid, content_ids: content_ids)

      redirect_to audits_allocations_url(redirect_params), notice: allocation.message
    end

    def destroy
      unallocation = UnallocateContent.call(content_ids: content_ids)

      redirect_to audits_allocations_url(redirect_params), notice: unallocation.message
    end

  private

    def user_uid
      params.fetch(:allocate_to)
    end

    def set_batch_value
      params[:content_ids] = FindContent
                               .paged(build_filter(per_page: batch_size))
                               .pluck(:content_id)
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
        :organisations,
        :primary,
        :user_uid
      )
    end
  end
end
