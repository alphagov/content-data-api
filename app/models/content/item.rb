class Content::Item < ApplicationRecord
  self.table_name = 'content_items'

  has_one :audit, primary_key: :content_id, foreign_key: :content_id, class_name: "Audits::Audit"
  has_one :allocation, primary_key: :content_id, foreign_key: :content_id, class_name: "Audits::Allocation"
  has_one :report_row, primary_key: :content_id, foreign_key: :content_id, class_name: "Audits::ReportRow"
  has_many :links, primary_key: :content_id, foreign_key: :source_content_id, class_name: "Content::Link"

  after_save { Audits::ReportRow.precompute(self) }

  scope :linked_by, ->(link_type) { where(links: { link_type: link_type }) }

  with_options through: :links, source: :target do |assoc|
    assoc.has_many :linked_policy_areas, -> { linked_by Content::Link::POLICY_AREAS }
    assoc.has_many :linked_policies, -> { linked_by Content::Link::POLICIES }
    assoc.has_many :linked_primary_org, -> { linked_by Content::Link::PRIMARY_ORG }
    assoc.has_many :linked_organisations, -> { linked_by Content::Link::ALL_ORGS }
    assoc.has_many :linked_topics, -> { linked_by Content::Link::TOPICS }
    assoc.has_many :linked_taxons, -> { linked_by Content::Link::TAXONOMIES }
  end

  attr_accessor :details

  def to_param
    content_id
  end

  def guidance?
    document_type == "guidance"
  end

  def withdrawn?
    false
  end

  def url
    "https://gov.uk#{base_path}"
  end

  def whitehall_url
    return unless publishing_app == "whitehall"
    "#{WHITEHALL}/government/admin/by-content-id/#{content_id}"
  end

  def self.all_taxons
    where(document_type: "taxon").order(:title)
  end

  def self.all_organisations
    where(document_type: "organisation").order(:title)
  end

  def self.all_document_types
    all
      .select(:document_type)
      .group(:document_type)
      .sort_by(&:document_type)
  end
end
