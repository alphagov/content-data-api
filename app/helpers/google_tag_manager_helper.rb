module GoogleTagManagerHelper
  def google_tag_manager
    @google_tag_manager ||= GoogleAnalytics::GoogleTagManager.new(
      current_user,
    )
  end
end
