class Api::DocumentTypesController < Api::BaseController
  def index
    @document_types = Queries::FindAllDocumentTypes.retrieve
    render json: @document_types
  end
end
