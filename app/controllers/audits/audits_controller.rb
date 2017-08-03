module Audits
  class AuditsController < BaseController
    before_action :content_items, only: %i(export)

    def index
      @content_items = FindContent.call(
        params[:theme],
        page: params[:page],
        organisations: params[:organisations],
        document_type: params[:document_type],
        audit_status: params[:audit_status],
        primary_org_only: primary_org_only?,
      ).decorate
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

    def export
      csv = Report.generate(@content_query.all_content_items, request)
      send_data(csv, filename: "Transformation_audit_report_CSV_download.csv")
    end

  private

    def audit
      @audit ||= Audit.find_or_initialize_by(content_item: content_item).decorate
    end

    def audits
      @audits ||= Audit.where(content_item: search.all_content_items)
    end

    def content_item
      @content_item ||= ContentItem.find_by(content_id: params.fetch(:content_item_content_id)).decorate
    end

    def content_items
      @content_items ||= search.content_items.decorate
    end

    def next_item
      @next_item ||= begin
        query = content_query
          .clone
          .after(content_item)
          .page(1)
          .per_page(1)

        apply_audit_status(query)
          .content_items
          .first
      end
    end

    def content_query
      @content_query ||= Content::Query.new
        .page(params[:page])
        .organisations(params[:organisations], primary_org_only?)
        .document_type(params[:document_type])
        .theme(params[:theme])
    end

    def search
      @search ||= apply_audit_status(content_query)
    end

    def audit_params
      params
        .require(:audits_audit)
        .permit(responses_attributes: [:id, :value, :question_id])
    end

    def error_message
      audit.errors.messages.values.join(', ').capitalize
    end

    def apply_audit_status(query)
      Audits::ContentQuery
        .new(scope: query.scope)
        .audit_status(params[:audit_status])
    end
  end
end
