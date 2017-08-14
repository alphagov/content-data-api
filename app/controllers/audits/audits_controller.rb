module Audits
  class AuditsController < BaseController
    decorates_assigned :audit, :content_item, :content_items, :next_content_item

    def index
      respond_to do |format|
        format.html { @content_items = FindContent.paged(build_filter) }
        format.csv do
          send_data(
            Report.generate(build_filter, request.url),
            filename: "Transformation_audit_report_CSV_download.csv"
          )
        end
      end
    end

    def show
      @content_item = Content::Item.find_by!(content_id: params.fetch(:content_item_content_id))
      @next_content_item = FindNextItem.call(@content_item, build_filter)
      @audit = Audit.find_or_initialize_by(content_item: @content_item)
      @audit.questions = @audit.template.questions if @audit.new_record?
    end

    def save
      @content_item = Content::Item.find_by!(content_id: params.fetch(:content_item_content_id))
      @next_content_item = FindNextItem.call(@content_item, build_filter)
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
        flash.now.alert = error_message
        render :show
      end
    end

  private

    def audit_params
      params
        .require(:audits_audit)
        .permit(responses_attributes: [:id, :value, :question_id])
    end

    def error_message
      @audit.errors.messages.values.join(', ').capitalize
    end
  end
end
