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

  def by_base_path(base_path)
    @base_path = base_path

    self
  end

  def run
    metrics = Facts::Metric.by_locale('en')

    if @from && @to
      metrics = metrics.between(@from, @to)
    end

    if @org_id
      metrics = metrics.by_organisation_id(@org_id)
    end

    if @with_edition_metrics
      metrics = metrics.with_edition_metrics
    end

    if @base_path
      metrics = metrics.by_base_path(@base_path)
    end

    metrics.joins(:dimensions_item)
  end
end
