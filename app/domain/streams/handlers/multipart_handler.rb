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
    update_editions(attr_list.map(&method(:find_old_edition)))
  end

private

  def find_old_edition(hash)
    { attrs: hash, old_edition: Dimensions::Edition.live_by_base_path(hash[:base_path]).first }
  end

  def deprecate_redundant_paths(current_base_paths)
    Dimensions::Edition.outdated_subpages(content_id, locale, current_base_paths).update(live: false)
  end
end
