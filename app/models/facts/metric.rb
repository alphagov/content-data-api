class Facts::Metric < ApplicationRecord
  belongs_to :dimensions_date, class_name: 'Dimensions::Date'
  belongs_to :dimensions_edition, class_name: 'Dimensions::Edition'

  has_one :facts_edition, through: :dimensions_edition

  validates :dimensions_date, presence: true
  validates :dimensions_edition, presence: true

  scope :with_edition_metrics, -> do
    joins(dimensions_edition: :facts_edition)
  end

  scope :for_yesterday, -> { where(dimensions_date: Dimensions::Date.find_or_create(Date.yesterday)) }
  scope :from_day_before_to, ->(date) { where(dimensions_date: Dimensions::Date.between(date - 1, date)) }
end
