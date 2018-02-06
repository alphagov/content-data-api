class ETL::GoogleAnalyticsReportDataJob < ApplicationJob
  sidekiq_options queue: 'google_analytics'

  def run(year, month, day, *_args)
    date = Date.new(year, month, day)
    date_dimension = Dimensions::Date.for(date)

    source = GoogleAnalyticsReportDataSource.new(date: date)
    transform = GoogleAnalyticsReportDataTransform.new(date_dimension: date_dimension)
    destination = GoogleAnalyticsReportDataDestination.new

    source
      .map { |report_data| transform.process(report_data) }
      .compact
      .each { |attributes| destination.write(attributes) }
  end
end
