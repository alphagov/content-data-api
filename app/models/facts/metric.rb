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
      pviews
      primary_organisation_title
      primary_organisation_content_id
      upviews
      feedex
      pdf_count
      doc_count
      readability
      useful_yes
      useful_no
      searches
      words
      chars
      sentences
      entrances
      exits
      bounce_rate
      avg_page_time
    ]
  end
end
