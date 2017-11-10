module AllocationMessageHelper
  def filtered_to_specific_user?
    filtered_to_current_user? || filtered_user.present?
  end

  def filtered_to_current_user?
    params[:allocated_to] == current_user.uid
  end

  def filtered_user
    @filtered_user ||= User.find_by(uid: params[:allocated_to])
  end
end
