module Audits
  class AllocationsController < BaseController
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

    def content_ids
      if params[:select_all_pages]
        FindContent.all(build_filter).pluck(:content_id)
      else
        params.fetch(:content_ids, [])
      end
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
