class Reports::FindSeries
  def between(from:, to:)
    @from = from
    @to = to

    self
  end

  def by_organisation_id(org_id)
    @org_id = org_id

    self
  end

  def by_document_type(document_type)
    @document_type = document_type

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

  def content_items
    slice_content_items
  end

  def run
    dates = slice_dates
    items = slice_content_items

    metrics = Facts::Metric.all
    metrics = metrics
      .joins(dimensions_edition: :facts_edition).merge(items)
      .joins(:dimensions_date).merge(dates)

    if @metric_names
      @metric_names.map { |metric_name| Reports::Series.new(metric_name, metrics) }
    else
      metrics
    end
  end

private

  def slice_dates
    dates = Dimensions::Date.all
    dates = dates.between(@from, @to) if @from && @to
    dates
  end

  def slice_content_items
    items = Dimensions::Edition.all
    items = items.by_locale('en')
    items = items.by_organisation_id(@org_id) unless @org_id.blank?
    items = items.by_base_path(@base_path) unless @base_path.blank?
    items = items.by_document_type(@document_type) unless @document_type.blank?
    items
  end
end
