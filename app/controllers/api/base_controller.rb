class Api::BaseController < ApplicationController
  rescue_from(ActionController::UnpermittedParameters) do |pme|
    error_response(
      "unknown-parameter",
      title: "One or more parameter names are invalid",
      invalid_params: pme.params
    )
  end

private

  def error_response(type, error_hash)
    # Type is an arbitrary URI identifying the error type
    # https://tools.ietf.org/html/rfc7807#section-3.1 recommends using
    # human-readable documentation for this, so point to our API docs.
    error_hash[:type] = "https://content-performance-api.publishing.service.gov.uk/errors/##{type}"
    render json: error_hash, status: :bad_request, content_type: "application/problem+json"
  end
end
