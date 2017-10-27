if Heroku.enabled?
  ApplicationController.class_eval do
    before_action :ensure_environment

    def authenticate_user!
    end

    def current_user
      User.last
    end

    private

    def ensure_environment
      if Rails.env.production?
        raise "This code should never run in production"
      end
    end
  end

  GovukAdminTemplate.configure do |c|
    c.show_signout = false
    c.disable_google_analytics = true
  end
end
