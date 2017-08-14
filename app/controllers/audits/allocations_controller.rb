module Audits
  class AllocationsController < BaseController
    def index
      @content_items = FindContent.paged(build_filter).decorate
    end

    def create
      content_ids = params.fetch(:content_ids)
      user_uid = params.fetch(:allocate_to)

      if user_uid == "no_one"
        UnallocateContent.call(content_ids: content_ids)
      else
        AllocateContent.call(user_uid: user_uid, content_ids: content_ids)
      end

      message = "#{content_ids.length} items assigned to #{current_user.name}"
      redirect_to audits_allocations_url(redirect_params), notice: message
    end

  private

    def redirect_params
      params.permit(:user_uid, :audit_status, :theme, :organisations, :primary, :document_type, :content_ids, :allocate_to, :allocated_to)
    end
  end
end
