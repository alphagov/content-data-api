class AuditsController < ApplicationController
  helper_method :filter_params, :primary_org_only?, :org_link_type
  before_action :content_items, only: %i(index report export)

  def index
  end

  def show
    audit.questions = audit.template.questions if audit.new_record?
    next_item
  end

  def next
    if next_item
      redirect_to content_item_audit_path(next_item, filter_params)
    else
      flash.alert = "Unable to find the next item to audit."
      redirect_to audits_path(filter_params.without(:page))
    end
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
    @content_item ||= ContentItem.find(params.fetch(:content_item_id)).decorate
  end

  def content_items
    @content_items ||= search.content_items.decorate
  end

  def next_item
    @next_item ||= content_items.next_item(content_item)
  end

  def search
    @search ||= (
      search = Search.new
      filter_by_audit_status!(search)
      filter_by_organisation!(search)
      filter_by_theme!(search)
      filter_by_document_type!(search)
      search.page = params[:page]
      search.execute
      search
    )
  end

  def audit_params
    params
      .require(:audit)
      .permit(responses_attributes: [:id, :value, :question_id])
  end

  def filter_params
    request
      .query_parameters
      .deep_symbolize_keys
  end

  def error_message
    audit.errors.messages.values.join(', ').capitalize
  end

  def filter_by_audit_status!(search)
    search.audit_status = params[:audit_status].to_sym if params[:audit_status].present?
  end

  def filter_by_organisation!(search)
    content_id = params[:organisations]
    search.filter_by(link_type: org_link_type, target_ids: content_id) if content_id.present?
  end

  def filter_by_theme!(search)
    search.theme = params[:theme] if params[:theme].present?
  end

  def filter_by_document_type!(search)
    search.document_type = params[:document_type] if params[:document_type].present?
  end

  def org_link_type
    primary_org_only? ? Link::PRIMARY_ORG : Link::ALL_ORGS
  end

  def primary_org_only?
    params[:primary].blank? || params[:primary] == "true"
  end
end
