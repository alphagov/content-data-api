class Finders::FindSeries
  def between(from:, to:)
    @from = from
    @to = to

    self
  end

  def by_warehouse_item_id(warehouse_item_id)
    @warehouse_item_id = warehouse_item_id

    self
  end

  def editions
    slice_editions
  end

  def run
    dates = slice_dates
    editions = slice_editions

    metrics = Facts::Metric.all
    metrics = metrics
      .joins(dimensions_edition: :facts_edition).merge(editions)
      .joins(:dimensions_date).merge(dates)

    metric_names = Metric.find_all_names
    metric_names.map { |metric_name| Finders::Series.new(metric_name, metrics) }
  end

private

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
