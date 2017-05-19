class AuditsController < ApplicationController
  def show
    audit.questions = template.questions if audit.new_record?
  end

  def save
    audit.user = current_user
    audit.update!(audit_params)
    flash.notice = "Audit saved successfully."
    redirect_to action: :show
  end

private

  def template
    @template ||= Template.new(audit)
  end

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
end
