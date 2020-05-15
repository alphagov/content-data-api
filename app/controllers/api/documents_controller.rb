class Api::DocumentsController < Api::BaseController
  before_action :validate_params!

  def children
    @document_id = params[:document_id]

    @parent = find_parent_edition!

    @documents = Finders::DocumentChildren.call(@parent, api_request.to_filter)
  end

private

  def api_request
    @api_request ||= Api::DocumentChildrenRequest.new(permitted_params)
  end

  def permitted_params
    params.permit(:document_id, :time_period, :sort, :format)
  end

  def find_parent_edition!
    parent = Dimensions::Edition.live.where(warehouse_item_id: @document_id).first
    raise Api::ParentNotFoundError, "#{params[:document_id]} not found" if parent.nil?

    parent
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
