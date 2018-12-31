class Queries::FindContent
  def self.call(filter:)
    raise ArgumentError unless filter.has_key?(:organisation_id) && filter.has_key?(:date_range)

    filter.assert_valid_keys :search_term, :date_range, :organisation_id, :document_type, :page, :page_size

    new(filter).call
  end

  def call
    view = Queries::SelectView.new(date_range).run
    results = view[:model_name].all
                .joins("INNER JOIN dimensions_editions ON aggregations_search_#{view[:table_name]}.dimensions_edition_id = dimensions_editions.id")
                .merge(slice_editions)
                .order(order_by)
                .page(@page)
                .per(@page_size)
    {
      results: results.pluck(*aggregates).map(&method(:array_to_hash)),
      page: @page,
      total_pages: results.total_pages,
      total_results: slice_editions.latest.count
    }
  end

private

  DEFAULT_PAGE_SIZE = 100
  ALL = 'all'.freeze
  NONE = 'none'.freeze

  def order_by
    'upviews desc'
  end

  attr_reader :organisation_id, :document_type, :date_range, :search_term

  def initialize(filter)
    @organisation_id = filter.fetch(:organisation_id)
    @document_type = filter.fetch(:document_type)
    @search_term = filter[:search_term]
    @page = filter[:page] || 1
    @page_size = filter[:page_size] || DEFAULT_PAGE_SIZE
    @date_range = filter.fetch(:date_range)
  end

  def aggregates
    %w(base_path title document_type upviews useful_yes useful_no searches)
  end

  def array_to_hash(array)
    satisfaction_responses = array[4].to_i + array[5].to_i
    {
      base_path: array[0],
      title: array[1],
      document_type: array[2],
      upviews: array[3].to_i,
      satisfaction: satisfaction_responses.zero? ? nil : (array[4].to_f / satisfaction_responses).to_f,
      satisfaction_score_responses: satisfaction_responses.to_i,
      searches: array[6].to_i,
    }
  end

  def slice_editions
    editions = Dimensions::Edition.relevant_content
    if organisation_id == NONE
      editions = editions.where('organisation_id IS NULL')
    elsif  organisation_id != ALL
      editions = editions.by_organisation_id(organisation_id)
    end
    editions = editions.where('document_type = ?', document_type) if document_type
    editions = editions.search(search_term) if search_term.present?
    editions
  end
end
