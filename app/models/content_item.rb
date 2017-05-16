class ContentItem < ApplicationRecord
  has_and_belongs_to_many :organisations
  has_and_belongs_to_many :taxonomies

  def url
    "https://gov.uk#{base_path}"
  end

  def self.create_or_update!(attributes)
    content_id = attributes.fetch(:content_id)
    content_item = self.find_or_create_by(content_id: content_id)

    content_item.add_organisations_by_id(attributes.fetch(:organisations, []))
    content_item.add_taxonomies_by_id(attributes.fetch(:taxons, []))

    attributes = content_item.existing_attributes(attributes)
    content_item.update!(attributes)
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

  def existing_attributes(attributes)
    attributes.slice(*self.attributes.symbolize_keys.keys)
  end
end
