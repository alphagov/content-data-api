require 'odyssey'

class Importers::ContentDetails
  attr_reader :items_service, :content_id, :base_path

  def self.run(*args)
    new(*args).run
  end

  def initialize(content_id, base_path, _ = {})
    @content_id = content_id
    @base_path = base_path
    @items_service = ItemsService.new
  end

  def run
    item = Dimensions::Item.find_by(content_id: content_id, latest: true)

    item_raw_json = items_service.fetch_raw_json(base_path)
    metadata = format_response(item_raw_json)
    item.update_attributes(metadata.merge!(raw_json: item_raw_json))

    ImportQualityMetricsJob.perform_async(item.id)
  rescue GdsApi::HTTPGone
    item.gone!
  rescue GdsApi::HTTPNotFound
    do_nothing
  end

private

  def do_nothing; end

  def format_metadata(raw_json)
    Importers::Metadata.parse(raw_json)
  end

  def format_response(item_raw_json)
    metadata = format_metadata(item_raw_json)
    metadata.merge(
      number_of_pdfs: number_of_pdfs(item_raw_json['details']),
      number_of_word_files: number_of_word_files(item_raw_json['details'])
    ).merge(extract_primary_organisation(item_raw_json['links']))
  end

  def extract_primary_organisation(links)
    Importers::PrimaryOrganisation.parse(links)
  end

  def number_of_pdfs(response_details)
    Performance::Metrics::NumberOfPdfs.parse(response_details)
  end

  def number_of_word_files(response_details)
    Performance::Metrics::NumberOfWordFiles.parse(response_details)
  end
end
