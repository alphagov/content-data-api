module Audits
  class AuditsController < BaseController
    decorates_assigned :audit, :content_item, :content_items

    def index
      respond_to do |format|
        format.html do
          params[:allocated_to] ||= current_user.uid
          params[:audit_status] ||= Audits::Audit::NON_AUDITED
          params[:primary] ||= 'true'

          @content_items = FindContent.paged(filter)
        end

        format.csv do
          send_data(
            Report.generate(filter, request.url),
            filename: "Transformation_audit_report_CSV_download.csv"
          )
        end
      end
    end

    def show
      @content_item = Content::Item.find_by!(content_id: params.fetch(:content_item_content_id))
      @audit = Audit.find_or_initialize_by(content_item: @content_item)
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
        items_remaining_count = FindContent.paged(filter).total_count

        if (next_content_item = FindNextItem.call(@content_item, filter))
          flash.notice = "Audit saved — #{helpers.number_with_delimiter(items_remaining_count)} " \
                         "#{'item'.pluralize(items_remaining_count)} remaining."
          redirect_to content_item_audit_path(next_content_item, filter_params)
        else
          flash.now.notice = "Audit saved — no items remaining."
          render :show
        end
      else
        render :show
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
