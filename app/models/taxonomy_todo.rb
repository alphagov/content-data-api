class TaxonomyTodo < ApplicationRecord
  belongs_to :content_item
  belongs_to :taxonomy_project
end
