class PublishingAPI::Handlers::SingleItemHandler < PublishingAPI::Handlers::BaseHandler
  def self.process(*args)
    new(*args).process
  end

  def initialize(message)
    @message = message
  end

  attr_reader :message, :old_item

  def process
    @old_item = Dimensions::Item.find_by(content_id: content_id, locale: locale, latest: true)
    document_text = Etl::Item::Content::Parser.extract_content(message.payload)
    return unless update_required? old_item: old_item, title: title, base_path: base_path, document_text: document_text
    new_item(document_text).promote!(old_item)
  end

private

  def new_item(document_text)
    item = Dimensions::Item.new(
      base_path: base_path,
      title: title,
      document_text: document_text,
      warehouse_item_id: "#{content_id}:#{locale}",
      **all_attributes
    )
    item.assign_attributes(facts_edition: Etl::Edition::Processor.process(old_item, item))
    item
  end
end
