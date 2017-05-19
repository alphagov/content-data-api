class Response < ApplicationRecord
  default_scope { order(id: :asc) }

  belongs_to :audit
  belongs_to :question

  validates :audit, presence: true
  validates :question, presence: true

  validates :value, presence: { message: "mandatory field missing" },
    if: -> { audit && audit.template.mandatory?(question) }
end
