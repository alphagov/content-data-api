require 'odyssey'

class Importers::ContentDetails
  include Concerns::Traceable
  attr_reader :items_service, :id,

  def self.run(*args)
    new(*args).run
  end

  def initialize(id, _ = {})
    @id = id
    @items_service = ItemsService.new
  end

  def run
    item = nil
    begin
      time(process: :content_details) do
        item = Dimensions::Item.find(id)
        item_raw_json = items_service.fetch_raw_json(item.base_path)
        attributes = Metadata::Parser.parse(item_raw_json)
        needs_quality_metrics = item.quality_metrics_required?(attributes)
        item.update_attributes(attributes)

        ImportQualityMetricsJob.perform_async(item.id) if needs_quality_metrics
      end
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
