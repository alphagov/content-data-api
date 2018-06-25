class PublishingAPI::MessageHandler
  require "deepsort"

  def self.process(*args)
    new(*args).process
  end

  def initialize(message)
    @message = message
  end

  def process
    items.each do |item|
      if is_links_update?
        item.process_links!
      else
        item.process!
      end
    end
  end

private

  attr_reader :message

  def get_old_items(new_base_paths)
    content_id = message.payload["content_id"]

    # Get everything with the same content id, so we can deprecate parts
    # that no longer exist, and get everything with the same base path
    # to maintain the constraint of only one latest item at each base path
    Dimensions::Item.where(content_id: content_id, latest: true).or(
      Dimensions::Item.where(base_path: new_base_paths, latest: true)
    )
  end

  def items
    adapter = PublishingAPI::MessageAdapter.new(message)
    new_items = adapter.to_dimension_items

    old_items = get_old_items(new_items.map(&:base_path))
    subpages = adapter.subpages_by_base_path
    result = new_items.map do |new_item|
      old_item = Dimensions::Item.find_by(base_path: new_item.base_path, latest: true)
      PublishingAPI::ItemHandler.new(
        old_item: old_item,
        new_item: new_item,
        subpage: new_item ? subpages[new_item.base_path] : nil
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
