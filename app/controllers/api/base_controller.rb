class Api::NotFoundError < StandardError
end

class Api::BaseController < ApplicationController
  before_action :set_cache_headers

  rescue_from(ActionController::UnpermittedParameters) do |pme|
    error_response(
      "unknown-parameter",
      title: "One or more parameter names are invalid",
      invalid_params: pme.params
    )
  end

  rescue_from(Api::NotFoundError) do
    not_found_response
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

  def format_base_path_param
    #  add '/' as param is received without leading forward slash which is needed to query by base_path.
    "/#{base_path}"
  end

  def from
    params[:from]
  end

  def to
    params[:to]
  end

private

  def set_cache_headers
    # Set cache headers to expire the page at 1am when we fetch new data.
    expiry_time = Time.zone.tomorrow.at_beginning_of_day.change(hour: 1)
    current_time = Time.zone.now
    cache_time = (expiry_time - current_time) % 24.hours

    expires_in cache_time, public: true
  end

  def error_response(type, error_hash)
    # Type is an arbitrary URI identifying the error type
    # https://tools.ietf.org/html/rfc7807#section-3.1 recommends using
    # human-readable documentation for this, so point to our API docs.
    error_hash[:type] = "https://content-performance-api.publishing.service.gov.uk/errors.html##{type}"
    render json: error_hash, status: :bad_request, content_type: "application/problem+json"
  end

  def not_found_response
    response_hash = {
      type: "https://content-performance-api.publishing.service.gov.uk/errors.html#base-path-not-found",
      title: 'The base path you are looking for cannot be found',
      invalid_params: %w[base_path]
    }
    render json: response_hash, status: :not_found, content_type: "application/problem+json"
  end
end
