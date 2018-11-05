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
end
