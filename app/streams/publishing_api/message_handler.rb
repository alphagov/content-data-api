class PublishingAPI::MessageHandler
  require "deepsort"

  def self.process(*args)
    new(*args).process
  end

  def initialize(message)
    @message = message

    @new_item = PublishingAPI::MessageAdapter.to_dimension_item(message)
    @old_item = Dimensions::Item.find_by(base_path: new_item.base_path, latest: true)
  end

  def process
    return unless new_item.older_than?(old_item)

    if is_links_update?
      grow_dimension! if links_have_changed?
    else
      grow_dimension!
    end
  end

private

  attr_reader :message, :new_item, :old_item

  def is_links_update?
    routing_key = message.delivery_info.routing_key
    routing_key.ends_with?('.links')
  end

  def links_have_changed?
    current_links = old_item.raw_json['expanded_links'].deep_sort
    new_links = new_item.raw_json['expanded_links'].deep_sort

    HashDiff::Comparison.new(current_links, new_links).diff.present?
  end

  def grow_dimension!
    new_item.promote!(old_item)
    Item::Processor.run(new_item, Date.today)
  end
end
