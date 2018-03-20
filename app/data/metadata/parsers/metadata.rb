class Metadata::Parsers::Metadata
  def self.parse(formatted_response)
    formatted_response.slice(
      'content_id',
      'title',
      'document_type',
      'content_purpose_document_supertype',
      'first_published_at',
      'public_updated_at',
    ).symbolize_keys
  end
end
