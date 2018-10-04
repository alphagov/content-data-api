class PublishingAPI::Handlers::SingleItemHandler < PublishingAPI::Handlers::BaseHandler
  def self.process(*args)
    new(*args).process
  end

  def initialize(message)
    @message = message
  end

  attr_reader :message, :old_edition

  def process
    @old_edition = Dimensions::Edition.find_by(content_id: content_id, locale: locale, latest: true)
    document_text = Etl::Edition::Content::Parser.extract_content(message.payload)
    return unless update_required? old_edition: old_edition, title: title, base_path: base_path, document_text: document_text
    new_edition(document_text).promote!(old_edition)
  end

private

  def new_edition(document_text)
    item = Dimensions::Edition.new(
      base_path: base_path,
      title: title,
      document_text: document_text,
      warehouse_item_id: "#{content_id}:#{locale}",
      **all_attributes
    )
    item.assign_attributes(facts_edition: Etl::Edition::Processor.process(old_edition, item))
    item
  end
end
