class Api::HealthcheckController < Api::BaseController
  skip_before_action :authenticate_user!
  skip_before_action :set_cache_headers

  def index
    render json: { status: "ok" }
  end
end
