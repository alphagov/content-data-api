class ContentItem < ApplicationRecord
  has_and_belongs_to_many :organisations
  has_and_belongs_to_many :taxonomies

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
end
