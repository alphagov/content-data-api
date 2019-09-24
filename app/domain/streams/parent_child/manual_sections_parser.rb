class Streams::ParentChild::ManualSectionsParser < Streams::ParentChild::BaseParser
  DOCUMENT_TYPES = %w[manual].freeze

  def self.get_children_ids(payload)
    sections = payload.dig("expanded_links", "sections") || []
    sections.map { |h| to_warehouse_id(h["content_id"], h["locale"]) }
  end

  def self.get_parent_id(_)
    nil
  end
end
