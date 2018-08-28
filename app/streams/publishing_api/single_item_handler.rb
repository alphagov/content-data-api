class PublishingAPI::SingleItemHandler
  include MessageAttributes

  def self.process(*args)
    new(*args).process
  end

  def initialize(message)
    @message = message
  end

  attr_reader :message, :old_item

  def process
    @old_item = Dimensions::Item.find_by(base_path: base_path, latest: true)
    return unless update_required? old_item: old_item, title: title, base_path: base_path
    new_item.promote!(old_item)
  end

private

    def new_item
      item = Dimensions::Item.new(
        base_path: base_path,
        title: title,
        document_text: Etl::Item::Content::Parser.extract_content(message.payload),
        **attributes
      )
      item.assign_attributes(facts_edition: Etl::Edition::Processor.process(old_item, item))
      item
    end
end
