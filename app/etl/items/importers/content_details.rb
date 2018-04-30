require 'odyssey'

class Items::Importers::ContentDetails
  include Concerns::Traceable

  attr_reader :content_store_client, :id, :fetch_quality_metrics

  def self.run(id, *_args, quality_metrics: true, **_options)
    new(id, quality_metrics: quality_metrics).run
  end

  def initialize(id, quality_metrics: true)
    @id = id
    @content_store_client = Item::Clients::ContentStore.new
    @fetch_quality_metrics = quality_metrics
  end

  def run
    item = nil
    begin
      item = Dimensions::Item.find(id)
      item_raw_json = content_store_client.fetch_raw_json(item.base_path)
      attributes = Item::Metadata::Parser.parse(item_raw_json)

      needs_quality_metrics = fetch_quality_metrics && item.quality_metrics_required?(attributes)

      item.update_attributes(attributes)

      Items::Jobs::ImportQualityMetricsJob.perform_async(item.id) if needs_quality_metrics
    rescue GdsApi::HTTPGone
      item.gone!
      handle_gone base_path: item.base_path
    rescue GdsApi::HTTPNotFound
      handle_not_found base_path: item.base_path
    end
  end

private

  def handle_not_found(base_path:)
    log process: :content_details, message: "NotFound when retrieving '#{base_path}' from content store"
  end

  def handle_gone(base_path)
    log process: :content_details, message: "Item '#{base_path}' has gone!"
  end
end
