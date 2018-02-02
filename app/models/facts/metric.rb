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

  validate :pageviews_and_unique_pageviews_are_dependent

private

  def pageviews_and_unique_pageviews_are_dependent
    if pageviews.present?
      if unique_pageviews.blank?
        errors.add(:unique_pageviews, :blank)
      elsif unique_pageviews.zero? && pageviews.nonzero?
        errors.add(:pageviews, "must be zero")
      end
    end

    if unique_pageviews.present?
      if pageviews.blank?
        errors.add(:pageviews, :blank)
      elsif pageviews.zero? && unique_pageviews.nonzero?
        errors.add(:unique_pageviews, "must be zero")
      end
    end

    if unique_pageviews.is_a?(Numeric) && pageviews.is_a?(Numeric) && unique_pageviews > pageviews
      errors.add(:unique_pageviews, :less_than_or_equal_to, count: pageviews)
    end
  end
end
