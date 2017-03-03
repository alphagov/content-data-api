class ContentItem < ApplicationRecord
  has_and_belongs_to_many :organisations
  has_and_belongs_to_many :taxonomies

  def url
    "https://gov.uk#{base_path}"
  end

  def self.create_or_update!(attributes, organisation)
    content_id = attributes.fetch(:content_id)
    content_item = self.find_or_create_by(content_id: content_id)

    content_item.add_organisation(organisation)
    content_item.add_taxonomies(attributes.fetch(:taxons))

    attributes = content_item.existing_attributes(attributes)
    content_item.update!(attributes)
  end

  def add_organisation(organisation)
    self.organisations << organisation unless self.organisations.include?(organisation)
  end

  def add_taxonomies(taxon_ids)
    taxon_ids.each do |taxon_id|
      taxon = Taxonomy.find_by(content_id: taxon_id)
      taxonomies << taxon unless taxon.nil? || taxonomies.include?(taxon)
    end
  end

  def existing_attributes(attributes)
    attributes.slice(*self.attributes.symbolize_keys.keys)
  end
end
