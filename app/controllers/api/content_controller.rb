class Api::ContentController < Api::BaseController
  before_action :validate_params!
  def index
    @content = Reports::Content.retrieve(from: params[:from], to: params[:to],
    organisation: params[:organisation])
    render json: { results: @content }.to_json
  end

  def api_request
    @api_request ||= Api::Request.new(params.permit(:from, :to, :metric, :base_path, :organisation, :format, metrics: []),
      requires_metrics: false,
      requires_base_path: false)
  end

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
