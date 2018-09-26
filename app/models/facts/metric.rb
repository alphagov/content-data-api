class Facts::Metric < ApplicationRecord
  belongs_to :dimensions_date, class_name: 'Dimensions::Date'
  belongs_to :dimensions_item, class_name: 'Dimensions::Item'

  has_one :facts_edition, through: :dimensions_item

  validates :dimensions_date, presence: true
  validates :dimensions_item, presence: true

  scope :with_edition_metrics, -> do
    joins(dimensions_item: :facts_edition)
  end

  scope :for_yesterday, -> { where(dimensions_date: Dimensions::Date.find_or_create(Date.yesterday)) }
  scope :from_day_before_to, ->(date) { where(dimensions_date: Dimensions::Date.between(date - 1, date)) }

  def self.csv_fields
    %i[
      date
      content_id
      base_path
      locale
      title
      description
      document_type
      schema_name
      content_purpose_document_supertype
      content_purpose_supergroup
      content_purpose_subgroup
      first_published_at
      public_updated_at
      pageviews
      primary_organisation_title
      primary_organisation_content_id
      unique_pageviews
      feedex_comments
      number_of_pdfs
      number_of_word_files
      readability_score
      is_this_useful_yes
      is_this_useful_no
      number_of_internal_searches
      word_count
      string_length
      sentence_count
      entrances
      exits
      bounce_rate
      avg_time_on_page
    ]
  end
end
