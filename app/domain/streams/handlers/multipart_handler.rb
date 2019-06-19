class Streams::Handlers::MultipartHandler < Streams::Handlers::BaseHandler
  def initialize(attr_list, content_id, locale, payload, routing_key)
    @attr_list = attr_list
    @content_id = content_id
    @locale = locale
    @payload = payload
    @routing_key = routing_key
  end

  attr_reader :attr_list, :content_id, :locale

  def process
    base_paths = attr_list.map { |hsh| hsh[:base_path] }
    deprecate_redundant_paths(base_paths)
    current_editions = update_editions(attr_list.map(&method(:find_old_edition)))
    set_parent_relationships(current_editions)
  end

private

  def set_parent_relationships(editions)
    parent = editions.first
    children = editions.drop(1)
    children.each do |child|
      child.update_attributes(parent: parent)
    end
  end

  def find_old_edition(hash)
    old_edition = Dimensions::Edition.find_latest(hash[:warehouse_item_id])
    { attrs: hash, old_edition: old_edition }
  end

  def deprecate_redundant_paths(current_base_paths)
    Dimensions::Edition.outdated_subpages(content_id, locale, current_base_paths).update(live: false)
  end
end
