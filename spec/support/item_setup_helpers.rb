module ItemSetupHelpers
  def create_metric(base_path: '/base-path', date:, edition: {}, daily: {}, item: {})
    dimensions_date = dimensions_date(date)
    dimensions_item = dimensions_item(item.merge(base_path: base_path), edition, dimensions_date)
    create :metric, daily.merge(
      dimensions_date: dimensions_date,
      dimensions_item: dimensions_item
    )
  end

  def create_edition(base_path: '/base-path', date:, edition: {}, item: {})
    dimensions_item(item.merge(base_path: base_path), edition, dimensions_date(date)).reload.facts_edition
  end

private

  def dimensions_item(attrs, edition, dimensions_date)
    existing_item = Dimensions::Item.find_by(warehouse_item_id: attrs[:warehouse_item_id], latest: attrs[:latest])
    return existing_item if existing_item
    new_item = create(:dimensions_item, attrs)
    create(:facts_edition, edition.merge(dimensions_item: new_item, dimensions_date: dimensions_date))
    new_item
  end

  def dimensions_date(date)
    create(:dimensions_date, date: get_date(date))
  end

  def get_date(date_or_str)
    return Date.parse(date_or_str) if date_or_str.class == String
    date_or_str
  end
end
