class TaxonomyTodo < ApplicationRecord
  belongs_to :content_item
  belongs_to :taxonomy_project
  has_and_belongs_to_many :terms
  belongs_to :user, primary_key: :uid, foreign_key: :completed_by, optional: true

  scope :still_todo, -> { where(completed_at: nil) }
  scope :done, -> { where('completed_at IS NOT NULL') }

  def completed?
    completed_at && completed_by
  end
end
