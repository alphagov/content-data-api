class PublishingAPI::MessageHandler
  def self.process(*args)
    new(*args).process
  end

  def initialize(message)
    @message = message
  end

  def process
    if is_links_update?
      item_handlers.each(&:process_links!)
    else
      item_handlers.each(&:process!)
    end
  end

private

  attr_reader :message

  def item_handlers
    adapter = PublishingAPI::MessageAdapter.new(message)
    new_items = adapter.new_dimension_items
    old_items = adapter.existing_dimension_items

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

  def is_links_update?
    routing_key = message.delivery_info.routing_key
    routing_key.ends_with?('.links')
  end
end
