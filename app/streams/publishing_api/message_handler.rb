class PublishingAPI::MessageHandler
  def self.process(*args)
    new(*args).process
  end

  def initialize(publishing_api_event)
    @publishing_api_event = publishing_api_event
  end

  def process
    if publishing_api_event.is_links_update?
      item_handlers.each(&:process_links!)
    else
      item_handlers.each(&:process!)
    end
  end

private

  attr_reader :publishing_api_event

  def item_handlers
    adapter = PublishingAPI::MessageAdapter.new(publishing_api_event)
    new_items = adapter.new_dimension_items

    old_items = Dimensions::Item.existing_latest_items(
      adapter.content_id,
      adapter.locale,
      new_items.map(&:base_path)
    )

    result = new_items.map do |new_item|
      old_item = Dimensions::Item.find_by(base_path: new_item.base_path, latest: true)
      PublishingAPI::ItemHandler.new(
        old_item: old_item,
        new_item: new_item,
      )
    end

    old_items.each(&:deprecate!)

    result
  end
end
