class Api::DocumentTypesController < Api::BaseController
  def index
      @document_types = DocumentType.find_all
      render json: @document_types
  end
end
