class Facts::Metric < ApplicationRecord
  belongs_to :dimensions_date, class_name: 'Dimensions::Date'
  belongs_to :dimensions_item, class_name: 'Dimensions::Item'

  validates :dimensions_date, presence: true
  validates :dimensions_item, presence: true

  scope :between, ->(from, to) do
    joins(:dimensions_date)
      .where('dimensions_dates.date BETWEEN ? AND ?', from, to)
  end

  scope :by_base_path, ->(base_path) do
    if base_path.present?
      joins(:dimensions_item)
        .where('dimensions_items.base_path like (?)', base_path)
    end
  end

  scope :by_content_id, ->(content_id) do
    joins(:dimensions_item)
      .where(dimensions_items: { content_id: content_id })
  end

  scope :metric_summary, -> do
    array = pluck(
      'COUNT(DISTINCT dimensions_items.content_id)',
      'SUM(pageviews)',
      'AVG(unique_pageviews)',
      'SUM(number_of_issues)',
      'AVG(number_of_pdfs)'
    ).first
    {
      total_items: array[0],
      pageviews: array[1],
      unique_pageviews: array[2],
      number_of_issues: array[3],
      number_of_pdfs: array[4]
    }
  end

  def self.valid_metric?(metric)
    METRIC_WHITELIST.include? metric
  end

  METRIC_WHITELIST = %w[pageviews unique_pageviews number_of_pdfs number_of_issues number_of_word_files].freeze
  private_constant :METRIC_WHITELIST
end
