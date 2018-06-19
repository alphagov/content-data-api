class PublishingAPI::MessageHandler
  require "deepsort"

  def self.process(*args)
    new(*args).process
  end

  def initialize(message)
    @message = message

    @new_items = PublishingAPI::MessageAdapter.to_dimension_items(message)
  end

  def process
    @new_items.each do |new_item|
      old_item = Dimensions::Item.find_by(base_path: new_item.base_path, latest: true)

      next unless new_item.newer_than?(old_item)
      if is_links_update?
        grow_dimension!(new_item, old_item) if links_have_changed?(new_item, old_item)
      else
        grow_dimension!(new_item, old_item)
      end
    end
  end

private

  attr_reader :message

  def is_links_update?
    routing_key = message.delivery_info.routing_key
    routing_key.ends_with?('.links')
  end

  def links_have_changed?(new_item, old_item)
    return true if old_item.nil?
    HashDiff::Comparison.new(
      old_item.expanded_links.deep_sort,
      new_item.expanded_links.deep_sort
    ).diff.present?
  end

  def grow_dimension!(new_item, old_item)
    new_item.promote!(old_item)
    Item::Processor.run(new_item, Date.today)
  end
end
