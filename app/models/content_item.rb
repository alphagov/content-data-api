class ContentItem < ApplicationRecord
  has_and_belongs_to_many :organisations

  def url
    "https://gov.uk#{base_path}"
  end

  def self.create_or_update!(attributes, organisation)
    content_id = attributes.fetch(:content_id)
    content_item = self.find_or_create_by(content_id: content_id)

    attributes = attributes.slice(*content_item.attributes.symbolize_keys.keys)

    content_item.update!(attributes)
    content_item.organisations << organisation unless content_item.organisations.include?(organisation)
  end
end
