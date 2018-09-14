class Reports::Content
  def self.retrieve(from:, to:)
    new(from, to).retrieve
  end

  def initialize(from, to)
    @from = from
    @to = to
  end

  def retrieve
    Facts::Metric.all
      .joins(dimensions_item: :facts_edition)
      .joins(:dimensions_date).merge(slice_dates)
      .group(group_columns)
      .limit(100)
      .pluck(*group_columns, *aggregates)
      .map(&method(:array_to_hash))
  end

private

  def aggregates
    [
      sum('unique_pageviews'),
      average_satisfaction_score,
      satifaction_score_responses,
      sum('number_of_internal_searches')
    ]
  end

  def group_columns
    %w[base_path title document_type].map { |col| Arel.sql(col) }
  end

  def sum(column)
    Arel.sql("SUM(#{column})")
  end

  def avg(column)
    Arel.sql("AVG(#{column})")
  end

  def satifaction_score_responses
    Arel.sql("SUM(is_this_useful_yes + is_this_useful_no)")
  end

  def average_satisfaction_score
    sql = <<-FOO
        CASE
          WHEN SUM(is_this_useful_yes + is_this_useful_no) > 0 THEN 1.0 * SUM(is_this_useful_yes) / SUM(is_this_useful_yes + is_this_useful_no)
          ELSE -1
          END
    FOO
    Arel.sql(sql)
  end

  def array_to_hash(array)
    {
      base_path: array[0],
      title: array[1],
      document_type: array[2],
      unique_pageviews: array[3],
      satisfaction_score: array[4].negative? ? nil : array[4].to_f,
      satisfaction_score_responses: array[5],
      number_of_internal_searches: array[6],
    }
  end

  def slice_dates
    Dimensions::Date.between(@from, @to)
  end
end
