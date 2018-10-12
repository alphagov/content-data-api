class DocumentTypeController < Api::BaseController
  def index
    @document_types = Queries::FindAllDocumentTypes.retrieve
  end
end
