module Audits
  class Audit < ApplicationRecord
    belongs_to :content_item, primary_key: :content_id, foreign_key: :content_id
    belongs_to :user, primary_key: :uid, foreign_key: :uid

    has_many :responses, inverse_of: :audit
    has_many :questions, through: :responses

    validates :content_item, presence: true
    validates :user, presence: true

    scope :passing, -> { where.not(id: failing) }
    scope :failing, -> { where(id: Response.failing.select(:audit_id)) }

    accepts_nested_attributes_for :responses

    after_save { ReportRow.precompute(content_item) }

    def template
      @template ||= Template.new
    end

    def passing?
      !failing?
    end

    def failing?
      responses.any?(&:failing?)
    end
  end
end
