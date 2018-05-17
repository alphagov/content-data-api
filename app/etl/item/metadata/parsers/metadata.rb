class Item::Metadata::Parsers::Metadata
  def self.parse(formatted_response)
    formatted_response.slice(
      'content_id',
      'base_path',
      'locale',
      'title',
      'document_type',
      'content_purpose_document_supertype',
      'content_purpose_supergroup',
      'content_purpose_subgroup',
      'first_published_at',
      'public_updated_at',
    ).symbolize_keys
  end
end
