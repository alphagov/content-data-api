class Facts::Metric < ApplicationRecord
  belongs_to :dimensions_date, class_name: 'Dimensions::Date'
  belongs_to :dimensions_item, class_name: 'Dimensions::Item'
  belongs_to :dimensions_organisation, class_name: 'Dimensions::Organisation', optional: true

  validates :dimensions_date, presence: true
  validates :dimensions_item, presence: true

  scope :by_date_name, -> do
    joins(:dimensions_date)
      .group(:date_name)
  end

  scope :for_organisation, ->(content_id:) do
    return unless content_id.present?

    joins(:dimensions_organisation)
      .where(
        dimensions_organisations: {
          content_id: content_id
        }
      )
  end
end
