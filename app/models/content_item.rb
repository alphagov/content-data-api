class ContentItem < ApplicationRecord
  has_and_belongs_to_many :organisations
  has_and_belongs_to_many :taxons
  has_one :audit, primary_key: :content_id, foreign_key: :content_id

  has_many :links,
    primary_key: :content_id,
    foreign_key: :source_content_id

  has_many :reverse_links,
    class_name: :Link,
    primary_key: :content_id,
    foreign_key: :target_content_id

  def self.targets_of(link_type:, scope_to_count: all)
    x = scope_to_count

    joins(:reverse_links)
      .where(links: { link_type: link_type })
      .group(:id)
      .select("content_items.*")
      .joins("LEFT JOIN (#{x.to_sql}) x ON x.content_id = links.source_content_id")
      .select("count(x.id) as incoming_links_count")
  end

  def self.next_item(current_item)
    ids = pluck(:id)
    index = ids.index(current_item.id)
    all[index + 1] if index
  end

  def topics
    linked_content(Link::TOPICS)
  end

  def organisations_tmp
    linked_content(Link::ALL_ORGS)
  end

  def policy_areas
    linked_content(Link::POLICY_AREAS)
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

  def add_organisations_by_id(orgs)
    orgs.each do |org|
      organisation = Organisation.find_by(content_id: org)
      organisations << organisation unless organisation.nil? || organisations.include?(organisation)
    end
  end

  def add_taxons_by_id(taxon_ids)
    taxon_ids.each do |taxon_id|
      taxon = Taxon.find_by(content_id: taxon_id)
      taxons << taxon unless taxon.nil? || taxons.include?(taxon)
    end
  end

private

  def linked_content(link_type)
    links = Link.where(link_type: link_type, source_content_id: content_id)

    ContentItem.where(content_id: links.select(:target_content_id))
  end
end
