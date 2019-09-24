class Aggregations::MonthlyMetric < ApplicationRecord
  belongs_to :dimensions_month, class_name: "Dimensions::Month"
  belongs_to :dimensions_edition, class_name: "Dimensions::Edition"

  validates :dimensions_month, presence: true
  validates :dimensions_edition, presence: true
end
