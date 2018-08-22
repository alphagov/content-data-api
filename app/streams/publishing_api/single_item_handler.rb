class PublishingAPI::SingleItemHandler
  include MessageAttributes

  def self.process(*args)
    new(*args).process
  end

  def initialize(message)
    @message = message
  end

  attr_reader :message

  def process
    item_handler.process!
  end

  private

  def item_handler
    old_item = Dimensions::Item.find_by(base_path: new_item.base_path, latest: true)
    PublishingAPI::ItemHandler.new(
      old_item: old_item,
      new_item: new_item,
    )
  end

  def new_item
    Dimensions::Item.new(
      base_path: base_path,
      title: title,
      document_text: Etl::Item::Content::Parser.extract_content(message.payload),
      **attributes
    )
  end
end
