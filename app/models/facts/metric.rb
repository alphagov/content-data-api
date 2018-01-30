class Facts::Metric < ApplicationRecord
  belongs_to :dimensions_date, class_name: 'Dimensions::Date'
  belongs_to :dimensions_item, class_name: 'Dimensions::Item'
  belongs_to :dimensions_organisation, class_name: 'Dimensions::Organisation', optional: true

  validates :dimensions_date, presence: true
  validates :dimensions_item, presence: true

  with_options numericality: { only_integer: true, allow_nil: true } do
    validates :pageviews
    validates :unique_pageviews
  end
end
