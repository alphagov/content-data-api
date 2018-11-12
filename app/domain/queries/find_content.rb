class Queries::FindContent
  DEFAULT_PAGE_SIZE = 100

  def self.call(filter:)
    raise ArgumentError unless filter.has_key?(:organisation_id) && filter.has_key?(:date_range)
    filter.assert_valid_keys :date_range, :organisation_id, :document_type, :page, :page_size

    new(filter).call
  end

  def call
    results = Aggregations::SearchLastThirtyDays.all
                .joins('INNER JOIN dimensions_editions ON aggregations_search_last_thirty_days.dimensions_edition_id = dimensions_editions.id')
                .merge(slice_editions)
                .order('upviews desc')
                .page(@page)
                .per(@page_size)
    {
      results: results.pluck(*aggregates).map(&method(:array_to_hash)),
      page: @page,
      total_pages: results.total_pages,
      total_results: slice_editions.count
    }
  end

private

  attr_reader :organisation_id, :document_type, :date_range

  def initialize(filter)
    @organisation_id = filter.fetch(:organisation_id)
    @document_type = filter.fetch(:document_type)
    @page = filter[:page] || 1
    @page_size = filter[:page_size] || DEFAULT_PAGE_SIZE
  end

  def aggregates
    %w(base_path title document_type upviews useful_yes useful_no searches)
  end

  def array_to_hash(array)
    satisfaction_responses = array[4] + array[5]
    {
      base_path: array[0],
      title: array[1],
      document_type: array[2],
      upviews: array[3],
      satisfaction: satisfaction_responses.zero? ? nil : array[4].to_f / satisfaction_responses,
      satisfaction_score_responses: satisfaction_responses,
      searches: array[6],
    }
  end

  def slice_editions
    editions = Dimensions::Edition.all
    editions = editions.where('organisation_id = ?', organisation_id)
    editions = editions.where('document_type = ?', document_type) if document_type
    editions
  end
end
