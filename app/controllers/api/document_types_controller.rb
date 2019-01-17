class Api::DocumentTypesController < Api::BaseController
  def index
    @document_types = Finders::AllDocumentTypes.retrieve
    render json: @document_types
  end
end
