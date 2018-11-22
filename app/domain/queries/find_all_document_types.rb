class Queries::FindAllDocumentTypes
  def self.retrieve
    new.retrieve
  end

  def retrieve
    Dimensions::Edition.latest
      .relevant_content
      .select(:document_type)
      .distinct
      .order(:document_type).to_a
  end
end
