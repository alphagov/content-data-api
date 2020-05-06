class Streams::ParentChild::ParentChildLinksParser < Streams::ParentChild::BaseParser
  DOCUMENT_TYPES = %w[
    guidance
    form
    foi_release
    promotional
    html_publication
    notice
    correspondence
    research
    official_statistics
    transparency
    statutory_guidance
    independent_report
    national_statistics
    corporate_report
    policy_paper
    decision
    map
    regulation
    international_treaty
    impact_assessment
    imported
  ].freeze

  def self.get_children_ids(payload)
    children = payload.dig("expanded_links", "children") || []

    children.map { |h| to_warehouse_id(h["content_id"], h["locale"]) }
  end

  def self.get_parent_id(payload)
    parent_array = payload.dig("expanded_links", "parent")
    return nil if parent_array.blank?

    to_warehouse_id(parent_array.first["content_id"], parent_array.first["locale"])
  end
end
