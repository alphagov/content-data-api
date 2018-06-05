class Reports::Series
  def for_en
    self
  end

  def between(from:, to:)
    @from = from
    @to = to

    self
  end

  def with_edition_metrics
    @with_edition_metrics = true

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

  def run
    items = Dimensions::Item.all
    metrics = Facts::Metric.all
    dates = Dimensions::Date.all

    dates = dates.between(@from, @to) if @from && @to
    metrics = metrics.with_edition_metrics if @with_edition_metrics

    items = items.by_locale('en')
    items = items.by_organisation_id(@org_id) unless @org_id.blank?
    items = items.by_base_path(@base_path) unless @base_path.blank?
    items = items.by_document_type(@document_type) unless @document_type.blank?

    metrics
      .joins(:dimensions_item).merge(items)
      .joins(:dimensions_date).merge(dates)
  end
end
