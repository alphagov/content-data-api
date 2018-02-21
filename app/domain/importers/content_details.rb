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
    response = items_service.fetch_raw_json(base_path)
    number_of_pdfs = Performance::Metrics::NumberOfPdfs.parse(response.to_h['details'])
    number_of_word_files = Performance::Metrics::NumberOfWordFiles.parse(response.to_h['details'])
    metadata = format_metadata(response.to_h)
    attributes =  metadata.merge(raw_json: response, number_of_pdfs: number_of_pdfs, number_of_word_files: number_of_word_files)
    item = Dimensions::Item.find_by(content_id: content_id, latest: true)
    item.update_attributes(attributes)
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

  def number_of_pdfs(formatted_response)
    Performance::Metrics::NumberOfPdfs.parse(formatted_response['details'])
  end
end
