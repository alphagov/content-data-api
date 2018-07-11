class PublishingApiEvent < ApplicationRecord
  has_many :dimensions_items, class_name: 'Dimensions::Item'

  validates :payload, presence: true
  validates :routing_key, presence: true

  def is_links_update?
    routing_key.ends_with?('.links')
  end
end
