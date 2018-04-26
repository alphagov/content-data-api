class Facts::Edition < ApplicationRecord
  belongs_to :dimensions_date, class_name: 'Dimensions::Date'
  belongs_to :dimensions_item, class_name: 'Dimensions::Item'

  validates :dimensions_date, presence: true
  validates :dimensions_item, presence: true

  scope :between, ->(from, to) do
    joins(:dimensions_date)
      .where('dimensions_dates.date BETWEEN ? AND ?', from, to)
  end
end
