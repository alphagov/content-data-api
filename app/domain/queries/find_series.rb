class Queries::FindSeries
  def between(from:, to:)
    @from = from
    @to = to

    self
  end

  def by_base_path(base_path)
    @base_path = base_path

    self
  end

  def by_metrics(metrics)
    @metric_names = metrics

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

    metric_names = @metric_names || Metric.find_all_names
    metric_names.map { |metric_name| Queries::Series.new(metric_name, metrics) }
  end

private

  def slice_dates
    dates = Dimensions::Date.all
    dates = dates.between(@from, @to) if @from && @to
    dates
  end

  def slice_editions
    editions = Dimensions::Edition.all
    editions = editions.by_locale('en')
    editions = editions.by_base_path(@base_path) unless @base_path.blank?
    editions
  end
end
