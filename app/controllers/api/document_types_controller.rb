class Api::DocumentTypesController < Api::BaseController
  def index
    @document_types = Finders::AllDocumentTypes.run
    render root: :document_types, json: @document_types
  end
end
