class GA::InternalSearchService
  def self.find_in_batches(*args, &block)
    new.find_in_batches(*args, &block)
  end

  def find_in_batches(date:, batch_size: 10_000)
    fetch_data(date: date)
      .lazy
      .map(&:to_h)
      .flat_map(&method(:extract_rows))
      .map(&method(:extract_dimensions_and_metrics))
      .map(&method(:append_labels))
      .map { |h| h['date'] = date.strftime('%F'); h }
      .each_slice(batch_size) { |slice| yield slice }
  end

  def client
    @client ||= GA::Client.new.build
  end

private

  def append_labels(values)
    page_path, internal_search = *values
    {
      'page_path' => page_path,
      'internal_search' => internal_search
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

  def fetch_data(date:)
    @data ||= client.fetch_all(items: :data) do |page_token, service|
      service
        .batch_get_reports(
          Google::Apis::AnalyticsreportingV4::GetReportsRequest.new(
            report_requests: [build_request(date: date).merge(page_token: page_token)]
          )
        )
        .reports
        .first
    end
  end

  def build_request(date:)
    {
      date_ranges: [
        { start_date: date.to_s("%Y-%m-%d"), end_date: date.to_s("%Y-%m-%d") },
      ],
      dimensions: [
        { name: 'ga:searchStartPage' },
      ],
      hide_totals: true,
      hide_value_ranges: true,
      metrics: [
        { expression: 'ga:searchUniques' }
      ],
      page_size: 10_000,
      view_id: ENV["GOOGLE_ANALYTICS_GOVUK_VIEW_ID"],
    }
  end
end
