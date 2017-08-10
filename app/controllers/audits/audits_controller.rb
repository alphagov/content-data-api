module Audits
  class AuditsController < BaseController
    def index
      respond_to do |format|
        format.html do
          @content_items = Content::ItemsDecorator.new(
            FindContent.paged(build_filter)
          )
        end
        format.csv do
          send_data(
            Report.generate(build_filter, request.url),
            filename: "Transformation_audit_report_CSV_download.csv"
          )
        end
      end
    end

    def show
      audit.questions = audit.template.questions if audit.new_record?
      next_item
    end

    def save
      audit.user = current_user
      updated = audit.update(audit_params)

      if next_item && updated
        flash.notice = "Saved successfully and continued to next item."
        redirect_to content_item_audit_path(next_item, filter_params)
      elsif updated
        flash.now.notice = "Saved successfully."
        render :show
      else
        flash.now.alert = error_message
        render :show
      end
    end

  private

    def audit
      @audit ||= Audit.find_or_initialize_by(content_item: content_item).decorate
    end

    def content_item
      @content_item ||= ContentItem.find_by!(content_id: params.fetch(:content_item_content_id)).decorate
    end

    def next_item
      @next_item ||= FindNextItem.call(content_item, build_filter)
    end

    def audit_params
      params
        .require(:audits_audit)
        .permit(responses_attributes: [:id, :value, :question_id])
    end

    def error_message
      audit.errors.messages.values.join(', ').capitalize
    end
  end
end
