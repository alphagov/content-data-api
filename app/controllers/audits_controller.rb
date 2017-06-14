class AuditsController < ApplicationController
  helper_method :filter_params

  def index
    content_items
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
      filter_by_link_types!(search)
      filter_by_subtheme!(search)
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
    search.audit_status = params[:audit_status] if params[:audit_status]
  end

  def filter_by_link_types!(search)
    params.slice(*Search::LINK_TYPE_FILTERS).each do |link_type, content_id|
      next if content_id.blank?
      search.filter_by(link_type: link_type, target_ids: content_id)
    end
  end

  def filter_by_subtheme!(search)
    search.subtheme = params[:subtheme] if params[:subtheme]
  end
end
