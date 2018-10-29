class PublishingAPI::Handlers::MultipartHandler < PublishingAPI::Handlers::BaseHandler
  def self.process(*args)
    new(*args).process
  end

  def initialize(message)
    @message = message
  end

  attr_reader :message

  def process
    deprecate_redundant_paths
    message.parts.each.with_index do |part, index|
      update_part(part, index)
    end
  end

private

  def deprecate_redundant_paths
    parts_base_paths = message.parts.map.with_index do |part, index|
      message.base_path_for_part(part, index)
    end
    Dimensions::Edition.outdated_subpages(content_id, locale, parts_base_paths).update(latest: false)
  end

  def update_part(part, index)
    base_path = message.base_path_for_part(part, index)
    old_edition = Dimensions::Edition.latest_by_base_path(base_path).first
    title = message.title_for(part)
    document_text = Etl::Edition::Content::Parser.extract_content(message.payload, subpage_path: part['slug'])
    return unless update_required?(old_edition: old_edition, base_path: base_path, title: title, document_text: document_text)
    new_edition = Dimensions::Edition.new(
      base_path: base_path,
      title: title,
      document_text: document_text,
      warehouse_item_id: "#{content_id}:#{locale}:#{base_path}",
      **all_attributes
    )
    new_edition.latest = false
    new_edition.assign_attributes(facts_edition: Etl::Edition::Processor.process(old_edition, new_edition))
    new_edition.promote!(old_edition)
  end
end
