class ContentItem < ApplicationRecord
  has_and_belongs_to_many :organisations
  has_and_belongs_to_many :taxonomies

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

  def add_taxonomies_by_id(taxons)
    taxons.each do |t|
      taxon = Taxonomy.find_by(content_id: t)
      taxonomies << taxon unless taxon.nil? || taxonomies.include?(taxon)
    end
  end

private

  def linked_content(link_type)
    links = Link.where(link_type: link_type, source_content_id: content_id)

    ContentItem.where(content_id: links.select(:target_content_id))
  end
end
