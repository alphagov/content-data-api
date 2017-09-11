module AllocationMessageHelper
  def show_allocation_message?
    filter.audit_status == Audits::Audit::NON_AUDITED && filtered_to_specific_user?
  end

  def filtered_to_specific_user?
    filtered_to_current_user? || filtered_user.present?
  end

  def filtered_to_current_user?
    filter.allocated_to == current_user.uid
  end

  def filtered_user
    @filtered_user ||= User.find_by(uid: filter.allocated_to)
  end
end
