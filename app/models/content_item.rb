class ContentItem < ApplicationRecord
  has_and_belongs_to_many :organisations
  has_and_belongs_to_many :taxons
  has_and_belongs_to_many :terms
  has_one :audit, primary_key: :content_id, foreign_key: :content_id


  def self.next_item(current_item)
    ids = pluck(:id)
    index = ids.index(current_item.id)
    all[index + 1] if index
  end

  def topics
    linked_content("topics")
  end

  def organisations_tmp
    linked_content("organisations")
  end

  def policy_areas
    linked_content("policy-areas")
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
