class PublishingAPI::MessageHandler
  def self.process(*args)
    new(*args).process
  end

  def initialize(message)
    @message = message
  end

  def process
    return if PublishingAPI::MessageValidator.is_old_message?(message)

    item_handlers.each(&:process!)
  end

private

  attr_reader :message

  def item_handlers
    adapter = PublishingAPI::MessageAdapter.new(message)
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

    if new_items.length < old_items.length
      old_items.each(&:deprecate!)
    end

    result
  end
end
