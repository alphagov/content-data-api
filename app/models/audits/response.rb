module Audits
  class Response < ApplicationRecord
    default_scope { order(id: :asc) }

    belongs_to :audit
    belongs_to :question

    validates :audit, presence: true
    validates :question, presence: true

    scope :boolean, -> { joins(:question).where(questions: { type: "Audits::BooleanQuestion" }) }
    scope :passing, -> { boolean.where(value: Audits::BooleanQuestion::PASS) }
    scope :failing, -> { boolean.where.not(id: passing) }

    validates :value, presence: { message: "mandatory field missing" },
      if: -> { audit && audit.template.mandatory?(question) }

    def boolean?
      question.is_a?(BooleanQuestion)
    end

    def passing?
      boolean? ? (value == BooleanQuestion::PASS) : true
    end

    def failing?
      !passing?
    end
  end
end
