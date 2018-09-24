class Api::MetricsController < Api::BaseController
  def index
    items = Metric.find_all
    render json: items
  end
end
