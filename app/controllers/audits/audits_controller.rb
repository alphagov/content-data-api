module Audits
  class AuditsController < BaseController
    decorates_assigned :audit, :content_item, :content_items, :next_content_item

    def index
      respond_to do |format|
        format.html do
          @default_filter = {
            allocated_to: current_user.uid,
            audit_status: Audits::Audit::NON_AUDITED,
          }

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
      @next_content_item = FindNextItem.call(@content_item, filter)
      @audit = Audit.find_or_initialize_by(content_item: @content_item)
    end

    def save
      @content_item = Content::Item.find_by!(content_id: params.fetch(:content_item_content_id))
      @next_content_item = FindNextItem.call(@content_item, filter)
      @audit = Audit.find_or_initialize_by(content_item: @content_item)
      @audit.user = current_user

      if @audit.update(audit_params)
        if @next_content_item
          flash.notice = "Saved successfully and continued to next item."
          redirect_to content_item_audit_path(@next_content_item, filter_params)
        else
          flash.now.notice = "Saved successfully."
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
            reformat
            similar
            similar_urls
          )
        )
    end
  end
end
