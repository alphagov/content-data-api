class GoogleAnalyticsService
  def client
    @client ||= GoogleAnalytics::Client.new.build
  end

  def page_views(base_paths)
    raise "base_paths isn't an array" unless base_paths.is_a?(Array)
    base_paths = base_paths.select(&:present?)
    return [] if base_paths.empty?

    request = GoogleAnalytics::Requests::PageViewsRequest.new.build(
      base_paths: base_paths,
      start_dates: [1.month.ago.strftime("%Y-%m-%d"), 6.months.ago.strftime("%Y-%m-%d")]
    )
    response = client.batch_get_reports(request)
    GoogleAnalytics::Responses::PageViewsResponse.new.parse(response)
  end

  def find_in_batches(date:, batch_size: 10_000)
    paged_report_data(date: date)
      .lazy
      .map(&:to_h)
      .flat_map(&method(:extract_rows))
      .map(&method(:extract_dimensions_and_metrics))
      .map(&method(:append_data_labels))
      .map { |h| h['date'] = date.strftime('%F'); h }
      .each_slice(batch_size) { |slice| yield slice }
  end

private

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

  def paged_report_data(date:)
    @data ||= client.fetch_all(items: :data) do |page_token, service|
      service
        .batch_get_reports(
          Google::Apis::AnalyticsreportingV4::GetReportsRequest.new(
            report_requests: [report_request(date: date).merge(page_token: page_token)]
          )
        )
        .reports
        .first
    end
  end

  def report_request(date:)
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
