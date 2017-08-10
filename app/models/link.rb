class Link < ApplicationRecord
  POLICY_AREAS = "policy_areas".freeze
  POLICIES = "policies".freeze
  PRIMARY_ORG = "primary_publishing_organisation".freeze
  ALL_ORGS = "organisations".freeze
  MAINSTREAM = "mainstream_browse_pages".freeze
  TOPICS = "topics".freeze
  TAXONOMIES = "taxons".freeze

  FILTERABLE_LINK_TYPES = [
    Link::PRIMARY_ORG,
    Link::ALL_ORGS,
    Link::TAXONOMIES,
  ].freeze

  GROUPABLE_LINK_TYPES = [
    Link::POLICY_AREAS,
    Link::POLICIES,
    Link::PRIMARY_ORG,
    Link::ALL_ORGS,
    Link::MAINSTREAM,
    Link::TOPICS,
  ].freeze

  after_save { Audits::ReportRow.precompute(source) }

  belongs_to :source,
    class_name: 'Content::Item',
    foreign_key: :source_content_id,
    primary_key: :content_id,
    optional: true

  belongs_to :target,
    class_name: 'Content::Item',
    foreign_key: :target_content_id,
    primary_key: :content_id,
    optional: true

  def self.all_link_types
    (FILTERABLE_LINK_TYPES + GROUPABLE_LINK_TYPES).uniq
  end
end
