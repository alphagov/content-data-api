require 'odyssey'

class Importers::ContentDetails
  include Concerns::Traceable
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
    item = nil
    begin
      time(process: :content_details) do
        item = Dimensions::Item.find_by(content_id: content_id, latest: true)

        item_raw_json = items_service.fetch_raw_json(base_path)
        attributes = Metadata::Parser.parse(item_raw_json)
        content_changed = item.content_hash != attributes[:content_hash]
        item.update_attributes(attributes)

        ImportQualityMetricsJob.perform_async(item.id) if content_changed
      end
    rescue GdsApi::HTTPGone
      item.gone!
      handle_gone
    rescue GdsApi::HTTPNotFound
      handle_not_found
    end
  end

private

  def handle_not_found
    log process: :content_details, message: "NotFound when retrieving '#{base_path}' from content store"
  end

  def handle_gone
    log process: :content_details, message: "Item '#{base_path}' has gone!"
  end
end
