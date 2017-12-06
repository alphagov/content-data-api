module Audits
  class AuditsController < BaseController
    decorates_assigned :audit, :content_item, :content_items

    def index
      respond_to do |format|
        format.html do
          params[:allocated_to] ||= current_user.uid
          params[:audit_status] ||= Audits::Audit::NON_AUDITED
          params[:organisations] ||= [current_user.organisation_content_id]
          params[:primary] = 'true' unless params.key?(:primary)

          @content_items = FindContent.paged(params_to_filter)
          render layout: "audits"
        end

        format.csv do
          send_data(
            Report.generate(params_to_filter, request.url),
            filename: "Transformation_audit_report_CSV_download.csv"
          )
        end
      end
    end

    def show
      @content_item = Content::Item.find_by!(content_id: params.fetch(:content_item_content_id))
      @audit = Audit.find_or_initialize_by(content_item: @content_item)
      render layout: "audit"
    end

    def save
      result = Audits::SaveAudit.call(
        attributes: audit_params,
        content_id: params.fetch(:content_item_content_id),
        user_uid: current_user.uid
      )

      @content_item = result.content_item
      @audit = result.audit

      if result.success
        items_remaining_count = FindContent.paged(params_to_filter).total_count

        if (next_content_item = FindNextItem.call(@content_item, params_to_filter))
          flash.notice = "Audit saved — #{helpers.number_with_delimiter(items_remaining_count)} " \
                         "#{'item'.pluralize(items_remaining_count)} remaining."
          redirect_to content_item_audit_path(next_content_item, filter_params)
        else
          flash.now.notice = "Audit saved — no items remaining."
          render :show, layout: "audit"
        end
      else
        render :show, layout: "audit"
      end
    end

  private

    def audit_params
      params
        .require(:audits_audit)
        .permit(
          %i(
            change_attachments
            change_body
            change_description
            change_title
            notes
            outdated
            redundant
            redirect_urls
            reformat
            similar
            similar_urls
          )
        )
    end
  end
end
