module Audits
  class AuditsController < ApplicationController
    helper_method :filter_params, :primary_org_only?, :audit_status_filter_enabled?

    before_action :content_items, only: %i(index report export)

    def index
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

    def report
    end

    def export
      csv = Report.generate(@search.unpaginated, request)
      send_data(csv, filename: "Transformation_audit_report_CSV_download.csv")
    end

    def guidance
      @body = Govspeak::Document.new(File.read("doc/guidance.md")).to_html.html_safe
    end

  private

    def audit
      @audit ||= Audit.find_or_initialize_by(content_item: content_item).decorate
    end

    def audits
      @audits ||= Audit.where(content_item: @search.unpaginated)
    end

    def content_item
      @content_item ||= ContentItem.find_by(content_id: params.fetch(:content_item_content_id)).decorate
    end

    def content_items
      @content_items ||= search.content_items.decorate
    end

    def next_item
      @next_item ||= content_items.next_item(content_item)
    end

    def content_query
      @content_query ||= Content::Query.new
        .page(params[:page])
        .organisations(params[:organisations], primary_org_only?)
        .document_type(params[:document_type])
        .theme(params[:theme])
    end

    def search
      @search ||= begin
        scope = content_query.scope

        if audit_status_filter_enabled?
          scope = Audits::FilteredContentQuery
            .filter_scope(scope)
            .audit_status(params[:audit_status])
            .scope
        end

        Search::Result.new(scope)
      end
    end

    def audit_params
      params
        .require(:audits_audit)
        .permit(responses_attributes: [:id, :value, :question_id])
    end

    def audit_status_filter_enabled?
      action_name != "report"
    end

    def filter_params
      request
        .query_parameters
        .deep_symbolize_keys
    end

    def error_message
      audit.errors.messages.values.join(', ').capitalize
    end

    def primary_org_only?
      params[:primary].blank? || params[:primary] == "true"
    end
  end
end
