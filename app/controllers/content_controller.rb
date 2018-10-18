class ContentController < Api::BaseController
  before_action :validate_params!

  def show
    @content = Queries::FindContent.retrieve(content_filters: api_request)
    @organisation_id = params[:organisation_id]
    render json: { results: @content, organisation_id: @organisation_id }.to_json
  end

  def api_request
    @api_request ||= Api::ContentRequest.new(permitted_params)
  end

private

  def permitted_params
    params.permit(:from, :to, :organisation_id, :document_type, :format)
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
