class Finders::Aggregations
  def between(from:, to:)
    @from = from
    @to = to

    self
  end

  def by_warehouse_item_id(warehouse_item_id)
    @warehouse_item_id = warehouse_item_id

    self
  end

  def run
    dates = slice_dates
    editions = slice_editions

    metrics = Facts::Metric.all
    metrics = metrics
      .joins(dimensions_edition: :facts_edition).merge(editions)
      .joins(:dimensions_date).merge(dates)
      .pick(*aggregations)

    result = build_response(metrics)
    result[:satisfaction] = calculate_satisfaction_score(result)

    result
  end

private

  def calculate_satisfaction_score(result)
    useful_yes = result[:useful_yes].to_i
    useful_no = result[:useful_no].to_i

    (useful_yes + useful_no).zero? ? nil : useful_yes / (useful_yes + useful_no).to_f
  end

  def build_response(metrics)
    metric_names = Metric.find_all_names
    Hash[metric_names.zip(metrics)].deep_symbolize_keys
  end

  def aggregations
    metric_names = Metric.find_all_names
    metric_names.map { |name| Arel.sql("SUM(#{name})") }
  end

  def slice_dates
    dates = Dimensions::Date.all
    dates = dates.between(@from, @to) if @from && @to
    dates
  end

  def slice_editions
    editions = Dimensions::Edition.all
    editions = editions.where(warehouse_item_id: @warehouse_item_id) if @warehouse_item_id.present?
    editions
  end
end
