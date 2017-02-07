class Organisation < ApplicationRecord
  has_and_belongs_to_many :content_items
end
