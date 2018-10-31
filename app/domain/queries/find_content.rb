class Queries::FindContent
  DEFAULT_PAGE_SIZE = 100
  def self.call(filter:)
    filter.assert_valid_keys :from, :to, :organisation_id, :document_type, :page, :page_size

    new(filter).call
  end

  def call
    results = Facts::Metric.all
      .joins(:dimensions_date).merge(slice_dates)
      .joins(:dimensions_edition).merge(slice_editions)
      .joins(latest_join)
      .group('latest.warehouse_item_id', *group_columns)
      .order(order_by)
      .page(@page)
      .per(@page_size)
    {
      results: results.pluck(*group_columns, *aggregates).map(&method(:array_to_hash)),
      page: @page,
      total_pages: results.total_pages,
      total_results: edition_count
    }
  end

private

  attr_reader :from, :to, :organisation_id, :document_type

  def initialize(filter)
    @from = filter.fetch(:from)
    @to = filter.fetch(:to)
    @organisation_id = filter.fetch(:organisation_id)
    @document_type = filter.fetch(:document_type)
    @page = filter[:page] || 1
    @page_size = filter[:page_size] || DEFAULT_PAGE_SIZE
  end

  def aggregates
    [
      sum('upviews'),
      sum('useful_yes'),
      sum('useful_no'),
      sum('searches')
    ]
  end

  def group_columns
    %w[latest.base_path latest.title latest.document_type].map { |col| Arel.sql(col) }
  end

  def order_by
    Arel.sql('latest.base_path')
  end

  def sum(column)
    Arel.sql("SUM(#{column})")
  end

  def latest_join
    "INNER JOIN dimensions_editions latest ON latest.warehouse_item_id = dimensions_editions.warehouse_item_id AND latest.latest = true"
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

  def edition_count
    editions = Dimensions::Edition.latest.by_organisation_id(organisation_id)
    editions = editions.by_document_type(document_type) if document_type
    editions.count
  end

  def slice_editions
    editions = Dimensions::Edition.all
    editions = editions.where('latest.organisation_id = ?', organisation_id)
    editions = editions.where('latest.document_type = ?', document_type) if document_type
    editions
  end

  def slice_dates
    Dimensions::Date.between(from, to)
  end
end
