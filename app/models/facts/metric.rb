class Facts::Metric < ApplicationRecord
  belongs_to :dimensions_date, class_name: 'Dimensions::Date'
  belongs_to :dimensions_item, class_name: 'Dimensions::Item'

  has_one :facts_edition, through: :dimensions_item

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

  scope :with_edition_metrics, -> do
    joins(:facts_edition)
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
      content_purpose_supergroup
      content_purpose_subgroup
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
      number_of_internal_searches
      word_count
      passive_count
      simplify_count
      string_length
      sentence_count
    ]
  end
end
