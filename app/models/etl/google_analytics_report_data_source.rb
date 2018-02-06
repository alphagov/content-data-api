require 'google/apis/analyticsreporting_v4'

class ETL::GoogleAnalyticsReportDataSource
  include Enumerable

  def initialize(reporting_service: GoogleAnalyticsService.new.client, date:)
    self.date = date
    self.reporting_service = reporting_service
  end

  def each
    return enum_for(:each) unless block_given?

    paged_report_data
      .lazy
      .map(&:to_h)
      .flat_map(&method(:extract_rows))
      .map(&method(:extract_dimensions_and_metrics))
      .map(&method(:append_data_labels))
      .each { |report_data| yield report_data }
  end

private

  attr_accessor :date, :reporting_service

  def append_data_labels(values)
    page_path, pageviews, unique_pageviews = *values

    {
      'ga:pagePath' => page_path,
      'ga:pageviews' => pageviews,
      'ga:uniquePageviews' => unique_pageviews,
    }
  end

  def extract_dimensions_and_metrics(row)
    dimensions = row.fetch(:dimensions)
    metrics = row.fetch(:metrics).flat_map do |metric|
      metric.fetch(:values).map(&:to_i)
    end

    dimensions + metrics
  end

  def extract_rows(report)
    report.fetch(:rows)
  end

  def paged_report_data
    @data ||= reporting_service.fetch_all(items: :data) do |page_token, service|
      service
        .batch_get_reports(
          Google::Apis::AnalyticsreportingV4::GetReportsRequest.new(
            report_requests: [report_request.merge(page_token: page_token)]
          )
        )
        .reports
        .first
    end
  end

  def report_request
    {
      date_ranges: [
        { start_date: date.to_s("%Y-%m-%d"), end_date: date.to_s("%Y-%m-%d") },
      ],
      dimensions: [
        { name: 'ga:pagePath' },
      ],
      hide_totals: true,
      hide_value_ranges: true,
      metrics: [
        { expression: 'ga:pageviews' },
        { expression: 'ga:uniquePageviews' },
      ],
      page_size: 10_000,
      view_id: ENV["GOOGLE_ANALYTICS_GOVUK_VIEW_ID"],
    }
  end
end
