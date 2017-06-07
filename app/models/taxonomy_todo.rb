class TaxonomyTodo < ApplicationRecord
  belongs_to :content_item
  belongs_to :taxonomy_project
  has_many :terms, through: :content_item

  scope :still_todo, -> { where(completed_at: nil) }

  def completed?
    completed_at && completed_by
  end
end
