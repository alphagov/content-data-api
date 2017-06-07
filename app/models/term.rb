class Term < ApplicationRecord
  has_and_belongs_to_many :taxonomy_todos
  belongs_to :taxonomy_project
end
