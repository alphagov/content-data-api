require 'odyssey'

class Importers::ContentDetails
  attr_reader :items_service, :content_id, :base_path, :content_quality_service

  def self.run(*args)
    new(*args).run
  end

  def initialize(content_id, base_path)
    @content_id = content_id
    @base_path = base_path
    @items_service = ItemsService.new
    @content_quality_service = ContentQualityService.new
  end

  def run
    item = Dimensions::Item.find_by(content_id: content_id, latest: true)
    item_raw_json = items_service.fetch_raw_json(base_path)
    metadata = format_response(item_raw_json)
    quality_metrics = content_quality_service.run(item.get_content)
    item.update_attributes(metadata.merge(quality_metrics))
  rescue GdsApi::HTTPGone
    item.gone!
  rescue GdsApi::HTTPNotFound
    do_nothing
  end

private

  def do_nothing; end

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

  def format_response(item_raw_json)
    metadata = format_metadata(item_raw_json.to_h)
    metadata.merge(
      raw_json: item_raw_json,
      number_of_pdfs: number_of_pdfs(item_raw_json.to_h['details']),
      number_of_word_files: number_of_word_files(item_raw_json.to_h['details'])
    )
  end

  def number_of_pdfs(response_details)
    Performance::Metrics::NumberOfPdfs.parse(response_details)
  end

  def number_of_word_files(response_details)
    Performance::Metrics::NumberOfWordFiles.parse(response_details)
  end
end
