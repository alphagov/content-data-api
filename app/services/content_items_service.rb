class ContentItemsService
  attr_accessor :client

  def initialize
    self.client = Clients::PublishingAPI.new
  end

  def content_ids
    client.content_ids
  end

  def fetch(content_id)
    ContentItem.new(client.fetch(content_id))
  end

  def links(source_content_id)
    client.links(source_content_id).flat_map do |link_type, content_ids|
      content_ids.map do |target_content_id|
        Link.new(
          source_content_id: source_content_id,
          link_type: link_type,
          target_content_id: target_content_id,
        )
      end
    end
  end
end
