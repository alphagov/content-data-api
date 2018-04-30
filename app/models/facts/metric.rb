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

  scope :by_organisation_id, ->(organisation_id) do
    if organisation_id.present?
      joins(:dimensions_item)
        .where(dimensions_items: { primary_organisation_content_id: organisation_id })
    end
  end

  scope :by_locale, ->(locale) do
    joins(:dimensions_item)
      .where(dimensions_items: { locale: locale })
  end

  scope :metric_summary, -> do
    array = pluck(
      'COUNT(DISTINCT dimensions_items.content_id)',
      'SUM(pageviews)',
      'AVG(unique_pageviews)',
      'SUM(feedex_comments)',
      'AVG(number_of_pdfs)',
      'AVG(number_of_word_files)',
      'AVG(spell_count)',
      'AVG(readability_score)',
      'AVG(is_this_useful_yes)',
      'AVG(is_this_useful_no)',
    ).first
    {
      total_items: array[0],
      pageviews: array[1],
      unique_pageviews: array[2],
      feedex_comments: array[3],
      number_of_pdfs: array[4],
      number_of_word_files: array[5],
      spell_count: array[6],
      readability_score: array[7],
      is_this_useful_yes: array[8],
      is_this_useful_no: array[9]
    }
  end

  def self.csv_fields
    %i[
      date
      content_id
      base_path
      locale
      title
      description
      document_type
      content_purpose_document_supertype
      first_published_at
      public_updated_at
      status
      pageviews
      primary_organisation_title
      primary_organisation_content_id
      unique_pageviews
      feedex_comments
      number_of_pdfs
      number_of_word_files
      readability_score
      spell_count
      is_this_useful_yes
      is_this_useful_no
    ]
  end
end
