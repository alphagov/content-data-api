class Api::HealthcheckController < ApiController
  def index
    database = ActiveRecord::Base.connected? ? :ok : :critical

    healthcheck = {
      checks: {
        database: database
      },
      status: database
    }

    render json: healthcheck
  end
end
