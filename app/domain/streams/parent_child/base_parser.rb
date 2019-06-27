class Streams::ParentChild::BaseParser
  def self.to_warehouse_id(content_id, locale)
    "#{content_id}:#{locale}"
  end
end
