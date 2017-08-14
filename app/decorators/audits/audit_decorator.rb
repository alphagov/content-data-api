module Audits
  class AuditDecorator < Draper::Decorator
    include ActionView::Helpers::NumberHelper

    delegate_all

    decorates_association :responses
    decorates_association :content_item
    decorates_association :user

    def incomplete?
      object.new_record?
    end

    def last_updated
      h.format_datetime(updated_at)
    end
  end
end
