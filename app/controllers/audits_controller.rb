class AuditsController < ApplicationController
  helper_method :filter_params, :primary_org_only?, :org_link_type,
    :audit_status_filter_enabled?

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
    @content_item ||= ContentItem.find(params.fetch(:content_item_id)).decorate
  end

  def content_items
    @content_items ||= search.content_items.decorate
  end

  def next_item
    @next_item ||= begin
      next_item_query = Search::QueryBuilder
        .from_query(query)
        .after(content_item)
        .page(1)
        .per_page(1)

      Search.new(next_item_query).content_items.first
    end
  end

  def query
    @query = begin
      query_builder = Search::QueryBuilder.new
        .page(params[:page])

      filter_by_audit_status!(query_builder) if audit_status_filter_enabled?
      filter_by_organisation!(query_builder)
      filter_by_theme!(query_builder)
      filter_by_document_type!(query_builder)

      query_builder
    end
  end

  def search
    @search ||= Search.new(query)
  end

  def audit_params
    params
      .require(:audit)
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

  def filter_by_audit_status!(query_builder)
    query_builder.audit_status(params[:audit_status].to_sym) if params[:audit_status].present?
  end

  def filter_by_organisation!(query_builder)
    content_id = params[:organisations]
    query_builder.filter_by(link_type: org_link_type, target_ids: content_id) if content_id.present?
  end

  def filter_by_theme!(query_builder)
    query_builder.theme(params[:theme]) if params[:theme].present?
  end

  def filter_by_document_type!(query_builder)
    query_builder.document_type(params[:document_type]) if params[:document_type].present?
  end

  def org_link_type
    primary_org_only? ? Link::PRIMARY_ORG : Link::ALL_ORGS
  end

  def primary_org_only?
    params[:primary].blank? || params[:primary] == "true"
  end
end
