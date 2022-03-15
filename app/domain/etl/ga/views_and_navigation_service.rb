class Etl::GA::ViewsAndNavigationService
  PAGE_PATH_LENGTH_LIMIT = 1500

  def self.find_in_batches(*args, **kwargs, &block)
    new.find_in_batches(*args, **kwargs, &block)
  end

  def find_in_batches(date:, batch_size: 10_000, &block)
    fetch_data(date: date)
      .lazy
      .map(&:to_h)
      .flat_map(&method(:extract_rows))
      .map(&method(:extract_dimensions_and_metrics))
      .map(&method(:append_data_labels))
      .reject(&method(:invalid_record?))
      .map { |hash| set_date(hash, date) }
      .each_slice(batch_size, &block)
  end

  def client
    @client ||= Etl::GA::Client.build
  end

private

  def set_date(hash, date)
    hash["date"] = date.strftime("%F")
    hash
  end

  def append_data_labels(values)
    page_path, pviews, upviews, entrances, exits, bounces, page_time = *values

    {
      "page_path" => page_path,
      "pviews" => pviews,
      "upviews" => upviews,
      "process_name" => "views",
      "entrances" => entrances,
      "exits" => exits,
      "bounces" => bounces,
      "page_time" => page_time,
    }
  end

  def invalid_record?(data)
    URI.parse(data["page_path"]) && data["page_path"].length > PAGE_PATH_LENGTH_LIMIT
  rescue URI::InvalidURIError
    true
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
    @fetch_data ||= client.fetch_all(items: :data) do |page_token, service|
      service
        .batch_get_reports(
          Google::Apis::AnalyticsreportingV4::GetReportsRequest.new(
            report_requests: [build_request(date: date).merge(page_token: page_token)],
          ),
        )
        .reports
        .first
    end
  end

  def build_request(date:)
    {
      date_ranges: [
        { start_date: date.to_fs("%Y-%m-%d"), end_date: date.to_fs("%Y-%m-%d") },
      ],
      dimensions: [
        { name: "ga:pagePath" },
      ],
      hide_totals: true,
      hide_value_ranges: true,
      metrics: [
        { expression: "ga:pageviews" },
        { expression: "ga:uniquePageviews" },
        { expression: "ga:entrances" },
        { expression: "ga:exits" },
        { expression: "ga:avgTimeOnPage" },
        { expression: "ga:bounces" },
        { expression: "ga:timeOnPage" },
      ],
      page_size: 10_000,
      view_id: ENV["GOOGLE_ANALYTICS_GOVUK_VIEW_ID"],
    }
  end
end
