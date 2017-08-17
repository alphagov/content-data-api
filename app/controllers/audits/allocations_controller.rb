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
      params.fetch(:content_ids) { [] }
    end

    def redirect_params
      params.permit(:user_uid, :audit_status, :theme, :organisations, :primary, :document_type, :content_ids, :allocated_to, :allocate_to)
    end
  end
end
