class Streams::ParentChild::ManualSectionManualParser < Streams::ParentChild::BaseParser
  DOCUMENT_TYPES = %w[manual_section].freeze

  def self.get_parent_id(payload)
    manuals = payload.dig('expanded_links', 'manual')
    return nil if manuals.blank?

    to_warehouse_id(manuals.first['content_id'], manuals.first['locale'])
  end

  def self.get_children_ids(_)
    []
  end
end
