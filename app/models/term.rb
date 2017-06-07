class Term < ApplicationRecord
  has_and_belongs_to_many :content_items
  belongs_to :taxonomy_project
end
