class AuditDecorator < Draper::Decorator
  delegate_all
  decorates_association :responses

  def user_name
    user ? user.name : "no one"
  end
end
