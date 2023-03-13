class ContentController < Api::BaseController
  before_action :validate_params!

  def show
    filter = api_request.to_filter
    content = Finders::Content.call(filter:)

    @content_items = content[:results]
    @page = content[:page]
    @total_pages = content[:total_pages]
    @total_results = content[:total_results]
  end

private

  def api_request
    @api_request ||= Api::ContentRequest.new(permitted_params)
  end

  def permitted_params
    params.permit(:from, :to, :organisation_id, :document_type, :format, :page, :page_size, :date_range, :search_term, :sort)
  end

  def validate_params!
    unless api_request.valid?
      error_response(
        "validation-error",
        title: "One or more parameters is invalid",
        invalid_params: api_request.errors.to_hash,
      )
    end
  end
end
