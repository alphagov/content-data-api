class Api::MetricsController < Api::BaseController
  before_action :validate_params!, except: :index

  def index
    items = Metric.find_all
    render json: items
  end

private

  def validate_params!
    unless api_request.valid?
      error_response(
        "validation-error",
        title: "One or more parameters is invalid",
        invalid_params: api_request.errors.to_hash
      )
    end
  end
end
