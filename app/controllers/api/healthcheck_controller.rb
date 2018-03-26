class Api::HealthcheckController < Api::BaseController
  skip_before_action :authenticate_user!
  skip_before_action :set_cache_headers

  def index
    database = ActiveRecord::Base.connected? ? :ok : :critical

    healthcheck = {
      checks: {
        database: { status: database }
      },
      status: :ok
    }

    render json: healthcheck
  end
end
