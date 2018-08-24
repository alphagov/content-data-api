class Facts::Metric < ApplicationRecord
  belongs_to :dimensions_date, class_name: 'Dimensions::Date'
  belongs_to :dimensions_item, class_name: 'Dimensions::Item'

  has_one :facts_edition, through: :dimensions_item

  validates :dimensions_date, presence: true
  validates :dimensions_item, presence: true

  scope :with_edition_metrics, -> do
    joins(dimensions_item: :facts_edition)
  end

  def is_this_useful_yes=(value)
    super(value)
    self.satisfaction_score = calculate_satisfaction_score
  end

  def is_this_useful_no=(value)
    super(value)
    self.satisfaction_score = calculate_satisfaction_score
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

private

  def calculate_satisfaction_score
    return nil if is_this_useful_yes.nil? && is_this_useful_no.nil?
    return 0 if is_this_useful_yes.nil? || is_this_useful_yes.zero?
    return 1 if is_this_useful_no.nil? || is_this_useful_no.zero?

    is_this_useful_yes.to_f / (is_this_useful_yes + is_this_useful_no).to_f
  end
end
