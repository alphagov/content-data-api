module Audits
  class Audit < ApplicationRecord
    ALL = :all
    AUDITED = :audited
    NON_AUDITED = :non_audited

    belongs_to :content_item, primary_key: :content_id, foreign_key: :content_id,
               class_name: 'Content::Item'
    belongs_to :user, primary_key: :uid, foreign_key: :uid

    validates :content_item, presence: true
    validates :user, presence: true

    validates :pass, inclusion: { in: [true, false] }
    validates :change_attachments, inclusion: { in: [true, false] }
    validates :change_body, inclusion: { in: [true, false] }
    validates :change_description, inclusion: { in: [true, false] }
    validates :change_title, inclusion: { in: [true, false] }
    validates :outdated, inclusion: { in: [true, false] }
    validates :redundant, inclusion: { in: [true, false] }
    validates :reformat, inclusion: { in: [true, false] }
    validates :similar, inclusion: { in: [true, false] }

    scope :passing, -> {
      where(pass: true)
    }

    scope :failing, -> {
      where(pass: false)
    }

    after_save { ReportRow.precompute(content_item) }

    def passing?
      pass
    end

    def failing?
      !passing?
    end
  end
end
