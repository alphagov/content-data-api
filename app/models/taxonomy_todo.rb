class TaxonomyTodo < ApplicationRecord
  STATE_TODO = 'todo'.freeze
  STATE_TAGGED = 'tagged'.freeze
  STATE_NOT_RELEVANT = 'not-relevant'.freeze
  STATE_DONT_KNOW = 'dont-know'.freeze
  DONE_STATES = [STATE_TAGGED, STATE_NOT_RELEVANT, STATE_DONT_KNOW].freeze

  belongs_to :content_item, class_name: 'Content::Item'
  belongs_to :taxonomy_project
  has_and_belongs_to_many :terms
  belongs_to :user, primary_key: :uid, foreign_key: :completed_by, optional: true

  scope :still_todo, -> { where(status: STATE_TODO) }
  scope :done, -> { where(status: DONE_STATES) }

  def completed?
    status.in?(DONE_STATES)
  end

  def tagged?
    status == STATE_TAGGED
  end

  def change_state!(state, user)
    update!(
      status: state,
      completed_at: Time.zone.now,
      completed_by: user.uid
    )
  end
end
