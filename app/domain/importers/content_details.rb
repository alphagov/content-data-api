class Importers::ContentDetails
  attr_reader :items_service, :content_id, :base_path

  def self.run(*args)
    new(*args).run
  end

  def initialize(content_id, base_path)
    @content_id = content_id
    @base_path = base_path
    @items_service = ItemsService.new
  end

  def run
    item = Dimensions::Item.find_by(content_id: content_id, latest: true)
    response = items_service.fetch_raw_json(base_path)
    attributes = format_response(response)
    item.update_attributes(attributes)
  rescue GdsApi::HTTPGone
    item.gone!
  end

private

  def format_metadata(formatted_response)
    formatted_response.slice(
      'content_id',
      'title',
      'document_type',
      'content_purpose_supertype',
      'first_published_at',
      'public_updated_at',
    )
  end

  def format_response(response)
    metadata = format_metadata(response.to_h)
    metadata.merge(
      raw_json: response,
      number_of_pdfs: number_of_pdfs(response.to_h['details']),
      number_of_word_files: number_of_word_files(response.to_h['details'])
    )
  end

  def number_of_pdfs(response_details)
    Performance::Metrics::NumberOfPdfs.parse(response_details)
  end

  def number_of_word_files(response_details)
    Performance::Metrics::NumberOfWordFiles.parse(response_details)
  end
end
