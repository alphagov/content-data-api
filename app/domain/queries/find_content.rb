class Queries::FindContent
  def self.retrieve(api_request:)
    new(api_request).retrieve
  end

  def initialize(api_request)
    @api_request = api_request
  end

  def retrieve
    Facts::Metric.all
      .joins(:dimensions_date).merge(slice_dates)
      .joins(:dimensions_edition).merge(slice_editions)
      .joins(latest_join)
      .group('latest.warehouse_item_id', *group_columns)
      .order(order_by)
      .limit(100)
      .pluck(*group_columns, *aggregates)
      .map(&method(:array_to_hash))
  end

private

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
    Arel.sql('latest.warehouse_item_id')
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

  def slice_editions
    Dimensions::Edition.by_organisation_id(@api_request.organisation_id)
  end

  def slice_dates
    Dimensions::Date.between(@api_request.from, @api_request.to)
  end
end
