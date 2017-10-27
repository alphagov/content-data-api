if Heroku.enabled?
  ApplicationController.class_eval do
    before_action :force_development!
    before_action :set_default_user

    def authenticate_user!
      user_id = params.dig(:heroku, :user_id)

      session[:heroku_user_id] = user_id if user_id.present?
    end

    def current_user
      User.find(session[:heroku_user_id])
    end

    def set_default_user
      session[:heroku_user_id] ||= User.first.id
    end

    private

    def force_development!
      if Rails.env.production?
        raise 'This code should never run in production'
      end
    end
  end

  GovukAdminTemplate.configure do |c|
    c.show_signout = false
    c.disable_google_analytics = true
  end
end
