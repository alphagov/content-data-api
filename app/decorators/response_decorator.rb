class ResponseDecorator < Draper::Decorator
  delegate_all
  decorates_association :question
end
