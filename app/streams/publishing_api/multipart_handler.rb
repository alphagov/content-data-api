class PublishingAPI::MultipartHandler
  include PublishingAPI::MessageAttributes

  def self.process(*args)
    new(*args).process
  end

  def initialize(message)
    @message = message
  end

  attr_reader :message

  def process
    item_handlers.each(&:process!)
  end

private

  def item_handlers
    old_items = Dimensions::Item.existing_latest_items(
      content_id,
      locale,
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

  def new_items
    multipart_message = PublishingAPI::MultipartMessage.new(message)
    multipart_message.parts.map.with_index do |part, index|
      Dimensions::Item.new(
        base_path: multipart_message.base_path_for_part(part, index),
        title: multipart_message.title_for(part),
        document_text: Etl::Item::Content::Parser.extract_content(message.payload, subpage_path: part['slug']),
        **attributes
      )
    end
  end
end
