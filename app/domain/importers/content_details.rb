require 'odyssey'

class Importers::ContentDetails
  include Concerns::Traceable
  attr_reader :items_service, :content_id, :base_path, :locale

  def self.run(*args)
    new(*args).run
  end

  def initialize(content_id, base_path, locale, _ = {})
    @content_id = content_id
    @base_path = base_path
    @locale = locale
    @items_service = ItemsService.new
  end

  def run
    item = nil
    begin
      time(process: :content_details) do
        item = Dimensions::Item.by_natural_key(content_id: content_id, locale: locale).first
        item_raw_json = items_service.fetch_raw_json(base_path)
        attributes = Metadata::Parser.parse(item_raw_json)
        content_changed = item.content_hash != attributes[:content_hash]
        item.update_attributes(attributes)

        import_quality_metrics_for_en(item) if content_changed
      end
    rescue GdsApi::HTTPGone
      item.gone!
      handle_gone
    rescue GdsApi::HTTPNotFound
      handle_not_found
    end
  end

private

  def import_quality_metrics_for_en(item)
    ImportQualityMetricsJob.perform_async(item.id) if locale == 'en'
  end

  def handle_not_found
    log process: :content_details, message: "NotFound when retrieving '#{base_path}' from content store"
  end

  def handle_gone
    log process: :content_details, message: "Item '#{base_path}' has gone!"
  end
end
