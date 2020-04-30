class Etl::GA::UserFeedbackService
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
      .map { |hash| set_date(hash, date) }
      .group_by { |h| h["page_path"] }
      .map { |h| format_data(h) }
      .each_slice(batch_size) { |slice| yield slice }
  end

  def client
    @client ||= Etl::GA::Client.build
  end

private

  def set_date(hash, date)
    hash["date"] = date.strftime("%F")
    hash
  end

  def append_labels(values)
    page_path, event_action, value = *values
    {
      "page_path" => page_path,
      event_action.to_s => value,
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
    @fetch_data ||= client.fetch_all(items: :data) do |page_token, service|
      service
        .batch_get_reports(
          Google::Apis::AnalyticsreportingV4::GetReportsRequest.new(
            report_requests: [build_request(date: date).merge(page_token: page_token)],
            use_resource_quotas: true,
          ),
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
        { name: "ga:pagePath" },
        { name: "ga:eventAction" },
      ],
      hide_totals: true,
      hide_value_ranges: true,
      metrics: [
        { expression: "ga:uniqueDimensionCombinations" },
      ],
      filters_expression: "ga:eventAction==ffNoClick,ga:eventAction==ffYesClick",
      page_size: 10_000,
      view_id: ENV["GOOGLE_ANALYTICS_GOVUK_VIEW_ID"],
    }
  end

  def format_data(hash)
    key, value = *hash
    no_action = value.find { |v| v["ffNoClick"] }
    yes_action = value.find { |v| v["ffYesClick"] }
    yes = yes_action ? yes_action["ffYesClick"] : 0
    no = no_action ? no_action["ffNoClick"] : 0
    {
      "page_path" => key,
      "useful_yes" => yes,
      "useful_no" => no,
      "date" => value.first["date"],
      "process_name" => "user_feedback",
    }
  end
end
