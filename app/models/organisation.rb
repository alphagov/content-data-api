class Organisation < ApplicationRecord
  has_many :content_items

  def total_content_items
    content_items.length
  end

  def name
    slug.tr('-', ' ').titleize
  end
end
