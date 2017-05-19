class AuditsController < ApplicationController
  def show
    audit.questions = template.questions if audit.new_record?
  end

  def save
    audit.user = current_user
    attributes = params.require(:audit).permit!
    audit.update!(attributes)
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
end
