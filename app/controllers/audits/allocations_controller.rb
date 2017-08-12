module Audits
  class AllocationsController < BaseController
    def index
      @content_items = FindContent.paged(build_filter).decorate
    end

    def create
      content_ids = params[:allocations][:content_ids]
      user_uid = params[:allocations][:user_uid]

      AllocateContent.call(
        user_uid: user_uid,
        content_ids: content_ids
      )

      message = "#{content_ids.length} items assigned to #{current_user.name}"
      redirect_to audits_allocations_path, notice: message
    end
  end
end
