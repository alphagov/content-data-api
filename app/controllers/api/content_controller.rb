class Api::ContentController < Api::BaseController
  before_action :validate_params!

  def index
    @content = Reports::Content.retrieve(
      from: params[:from],
      to: params[:to],
      organisation_id: params[:organisation_id]
    )
    render json: { results: @content }.to_json
  end

  def api_request
    @api_request ||= Api::ContentRequest.new(permitted_params)
  end

private

  def permitted_params
    params.permit(:from, :to, :organisation_id, :format)
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
