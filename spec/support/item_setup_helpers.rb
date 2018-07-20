module ItemSetupHelpers
  def create_metric(base_path:, date:, edition: {}, daily: {}, item: {})
    dimensions_item = dimensions_item(item.merge(base_path: base_path))
    dimensions_date = dimensions_date(date)
    ensure_edition_exists(dimensions_item, dimensions_date, edition)
    create :metric, daily.merge(
      dimensions_date: dimensions_date,
      dimensions_item: dimensions_item
    )
  end

  def create_edition(base_path:, date:, edition:, item:)
    ensure_edition_exists(dimensions_item(item.merge(base_path: base_path)), dimensions_date(date), edition)
  end

private

  def ensure_edition_exists(dimensions_item, dimensions_date, edition_attrs)
    if Facts::Edition.find_by(dimensions_item: dimensions_item).nil?
      create(:facts_edition, edition_attrs.merge(dimensions_item: dimensions_item, dimensions_date: dimensions_date))
    end
  end

  def dimensions_item(attrs)
    create(:dimensions_item, attrs)
  end

  def dimensions_date(date)
    create(:dimensions_date, date: get_date(date))
  end

  def get_date(date_or_str)
    return Date.parse(date_or_str) if date_or_str.class == String
    date_or_str
  end
end
