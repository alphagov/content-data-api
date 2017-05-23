class AuditDecorator < Draper::Decorator
  delegate_all

  def user_name
    user ? user.name : "no one"
  end
end
