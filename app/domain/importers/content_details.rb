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
        content_changed = item.content_hash != attributes[:content_hash]
        item.update_attributes(attributes)

        import_quality_metrics_for_en(item) if content_changed
      end
    rescue GdsApi::HTTPGone
      item.gone!
      handle_gone base_path: item.base_path
    rescue GdsApi::HTTPNotFound
      handle_not_found base_path: item.base_path
    end
  end

private

  def import_quality_metrics_for_en(item)
    ImportQualityMetricsJob.perform_async(item.id) if item.locale == 'en'
  end

  def handle_not_found(base_path:)
    log process: :content_details, message: "NotFound when retrieving '#{base_path}' from content store"
  end

  def handle_gone(base_path)
    log process: :content_details, message: "Item '#{base_path}' has gone!"
  end
end
