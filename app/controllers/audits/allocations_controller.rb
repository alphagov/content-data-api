module Audits
  class AllocationsController < BaseController
    before_action :set_batch_value, only: %w(destroy create), if: -> { batch_size > content_ids.size }

    decorates_assigned :content_items

    def index
      @default_filter = {
        allocated_to: :no_one,
        audit_status: Audits::Audit::NON_AUDITED,
        organisations: [current_user.organisation_content_id],
      }

      @content_items = FindContent.paged(filter)
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

    def user_uid
      params.fetch(:allocate_to)
    end

    def set_batch_value
      params[:content_ids] = FindContent
                               .paged(filter(per_page: batch_size))
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
