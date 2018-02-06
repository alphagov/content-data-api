class ETL::GoogleAnalyticsReportDataTransform
  def initialize(date_dimension:, item_dimension_scope: Dimensions::Item)
    self.date_dimension = date_dimension
    self.item_dimension_scope = item_dimension_scope
  end

  def process(report_row)
    return unless (item_dimension_id = first_id_for_link(report_row['ga:pagePath']))

    {
      dimensions_date_id: date_dimension.id,
      dimensions_item_id: item_dimension_id,
      pageviews: report_row['ga:pageviews'],
      unique_pageviews: report_row['ga:uniquePageviews'],
    }
  end

private

  attr_accessor :date_dimension, :item_dimension_scope

  def first_id_for_link(link)
    item_dimension_scope
      .where(latest: true, link: link)
      .pluck(:id)
      .first
  end
end
