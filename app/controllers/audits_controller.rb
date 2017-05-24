class AuditsController < ApplicationController
  def index
    query = Queries::ContentItemsQuery.new(query_options)
    @content_items = query.paginated_results.decorate
  end

  def show
    audit.questions = audit.template.questions if audit.new_record?
  end

  def save
    audit.user = current_user

    if audit.update(audit_params)
      flash.now.notice = "Saved successfully."
    else
      flash.now.alert = error_message
    end

    render :show
  end

private

  def audit
    @audit ||= Audit.find_or_initialize_by(content_item: content_item).decorate
  end

  def content_item
    @content_item ||= ContentItem.find(params.fetch(:content_item_id)).decorate
  end

  def audit_params
    params
      .require(:audit)
      .permit(responses_attributes: [:id, :value, :question_id])
  end

  def error_message
    audit.errors.messages.values.join(', ').capitalize
  end

  def query_options
    {
      sort: params[:sort],
      order: params[:order],
      query: params[:query],
      page: params[:page]
    }
  end
end
