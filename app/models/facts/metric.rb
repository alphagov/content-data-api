class Facts::Metric < ApplicationRecord
  belongs_to :dimensions_date, class_name: 'Dimensions::Date'
  belongs_to :dimensions_edition, class_name: 'Dimensions::Edition'

  has_one :facts_edition, through: :dimensions_edition

  delegate :pdf_count,
           :doc_count,
           :readability,
           :chars,
           :sentences,
           :words,
           :reading_time,
           to: :facts_edition

  validates :dimensions_date, presence: true
  validates :dimensions_edition, presence: true

  scope :for_yesterday, -> { where(dimensions_date: Dimensions::Date.for_date(Date.yesterday)) }
  scope :from_day_before_to, ->(date) { where(dimensions_date: Dimensions::Date.between(date - 1, date)) }
end
