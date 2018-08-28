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
    deprecate_redundant_paths
    multipart_message.parts.each.with_index do |part, index|
      update_part(part, index)
    end
  end

  private

    def deprecate_redundant_paths
      parts_base_paths = multipart_message.parts.map.with_index do |part, index|
        multipart_message.base_path_for_part(part, index)
      end
      Dimensions::Item.outdated_subpages(content_id, locale, parts_base_paths).update(latest: false)
    end

    def update_part(part, index)
      base_path = multipart_message.base_path_for_part(part, index)
      old_item = Dimensions::Item.find_by_base_path(base_path)
      title = multipart_message.title_for(part)
      return unless update_required?(old_item: old_item, base_path: base_path, title: title)
      Dimensions::Item.create(
        base_path: base_path,
        title: title,
        document_text: Etl::Item::Content::Parser.extract_content(message.payload, subpage_path: part['slug']),
        **attributes
      ).promote!(old_item)
    end


    def multipart_message
      @multipart_message ||= PublishingAPI::MultipartMessage.new(message)
    end
end
