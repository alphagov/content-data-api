class Finders::AllDocumentTypes
  def self.run
    new.run
  end

  def run
    Dimensions::Edition
      .latest
      .select('distinct document_type')
      .where.not(document_type: DocumentType::IGNORED_TYPES)
      .order(document_type: :asc)
      .map do |edition|
        DocumentType.new(id: edition.document_type, name: edition.document_type.humanize)
      end
  end
end
