class Facts::Metric < ApplicationRecord
  belongs_to :dimensions_date, class_name: 'Dimensions::Date'
  belongs_to :dimensions_item, class_name: 'Dimensions::Item'
  belongs_to :dimensions_organisation, class_name: 'Dimensions::Organisation', optional: true

  validates :dimensions_date, presence: true
  validates :dimensions_item, presence: true
  validates :pageviews, numericality: { only_integer: true }
  validates :unique_pageviews, numericality: { only_integer: true }
end
