class Api::DocumentTypesController < Api::BaseController
  def index
    @document_types = Finders::AllDocumentTypes.run
    render json: @document_types
  end
end
