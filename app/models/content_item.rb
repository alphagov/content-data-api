class ContentItem < ApplicationRecord
  has_one :audit, primary_key: :content_id, foreign_key: :content_id
  has_one :report_row, primary_key: :content_id, foreign_key: :content_id
  has_many :links, primary_key: :content_id, foreign_key: :source_content_id

  after_save { ReportRow.precompute(self) }

  Search.all_link_types.each do |link_type|
    has_many(
      :"linked_#{link_type}",
      -> { where(links: { link_type: link_type }) },
      through: :links,
      source: :target,
    )
  end

  attr_accessor :details

  def self.targets_of(link_type:, scope_to_count: all)
    sql = scope_to_count.to_sql.presence
    sql ||= "select * from content_items where id = -1"

    nested = Link
      .select(:target_content_id, "count(x.id) as c")
      .joins("join (#{sql}) x on content_id = source_content_id")
      .where(link_type: link_type)
      .group(:target_content_id)

    ContentItem
      .select("*, c as incoming_links_count")
      .joins("join (#{nested.to_sql}) x on target_content_id = content_id")
  end

  def self.next_item(current_item)
    ids = pluck(:id)
    index = ids.index(current_item.id)
    all[index + 1] if index
  end

  def self.document_type_counts
    all
      .select(:document_type, "count(1) as count")
      .group(:document_type)
      .map { |r| [r.document_type, r.count] }
      .sort_by(&:first)
      .to_h
  end

  def title_with_count
    if respond_to?(:incoming_links_count)
      "#{title} (#{incoming_links_count})"
    else
      title
    end
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
end
