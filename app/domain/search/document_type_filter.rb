class Search
  class DocumentTypeFilter
    attr_accessor :document_type

    def initialize(document_type)
      self.document_type = document_type
    end

    def apply(scope)
      scope.where(document_type: document_type)
    end
  end
end
