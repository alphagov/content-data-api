module Audits
  class Audit < ApplicationRecord
    ALL = :all
    AUDITED = :audited
    NON_AUDITED = :non_audited
    ALLOCATED_TO = :allocated_to

    belongs_to :content_item, primary_key: :content_id, foreign_key: :content_id,
               class_name: 'Content::Item'
    belongs_to :user, primary_key: :uid, foreign_key: :uid

    validates :content_item, presence: true
    validates :user, presence: true

    validates :change_attachments, inclusion: { in: [true, false] }
    validates :change_body, inclusion: { in: [true, false] }
    validates :change_description, inclusion: { in: [true, false] }
    validates :change_title, inclusion: { in: [true, false] }
    validates :outdated, inclusion: { in: [true, false] }
    validates :redundant, inclusion: { in: [true, false] }
    validates :reformat, inclusion: { in: [true, false] }
    validates :similar, inclusion: { in: [true, false] }

    scope :passing, -> {
      where(
        change_attachments: false,
        change_body: false,
        change_description: false,
        change_title: false,
        outdated: false,
        redundant: false,
        reformat: false,
        similar: false,
      )
    }

    scope :failing, -> {
      where(change_attachments: true)
        .or(where(change_body: true))
        .or(where(change_description: true))
        .or(where(change_title: true))
        .or(where(outdated: true))
        .or(where(redundant: true))
        .or(where(reformat: true))
        .or(where(similar: true))
    }

    after_save { ReportRow.precompute(content_item) }

    def passing?
      !failing?
    end

    def failing?
      [
        change_attachments,
        change_body,
        change_description,
        change_title,
        outdated,
        redundant,
        reformat,
        similar,
      ].any?
    end
  end
end
