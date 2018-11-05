class Streams::Handlers::MultipartHandler < Streams::Handlers::BaseHandler
  def self.process(*args)
    new(*args).process
  end

  def initialize(message)
    @message = message
  end

  attr_reader :message

  def process
    edition_attribute_list = message.extract_edition_attributes
    base_paths = edition_attribute_list.map { |hsh| hsh[:base_path] }
    deprecate_redundant_paths(base_paths)
    update_editions(edition_attribute_list.map(&method(:find_old_edition)))
  end

private

  def find_old_edition(hash)
    { attrs: hash, old_edition: Dimensions::Edition.latest_by_base_path(hash[:base_path]).first }
  end

  def deprecate_redundant_paths(current_base_paths)
    Dimensions::Edition.outdated_subpages(content_id, locale, current_base_paths).update(latest: false)
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
