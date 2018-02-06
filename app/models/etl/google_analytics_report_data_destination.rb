class ETL::GoogleAnalyticsReportDataDestination
  def write(dimensions_date_id:, dimensions_item_id:, pageviews:, unique_pageviews:)
    Facts::Metric
      .where(
        dimensions_date_id: dimensions_date_id,
        dimensions_item_id: dimensions_item_id
      )
      .first_or_initialize
      .update!(
        pageviews: pageviews,
        unique_pageviews: unique_pageviews
      )
  end
end
