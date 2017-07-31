class ContentItem < ApplicationRecord
  has_one :audit, primary_key: :content_id, foreign_key: :content_id, class_name: "Audits::Audit"
  has_one :report_row, primary_key: :content_id, foreign_key: :content_id, class_name: "Audits::ReportRow"
  has_many :links, primary_key: :content_id, foreign_key: :source_content_id

  after_save { Audits::ReportRow.precompute(self) }

  Search.all_link_types.each do |link_type|
    has_many(
      :"linked_#{link_type}",
      -> { where(links: { link_type: link_type }) },
      through: :links,
      source: :target,
    )
  end

  attr_accessor :details

  def to_param
    content_id
  end

  def self.next_item(current_item)
    ids = pluck(:id)
    index = ids.index(current_item.id)
    all[index + 1] if index
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
