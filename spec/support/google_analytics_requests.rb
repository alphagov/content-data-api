module GoogleAnalyticsRequests
  def build_report_data(*report_rows)
    Google::Apis::AnalyticsreportingV4::ReportData.new(rows: report_rows)
  end

  def build_report_row(dimensions:, metrics:)
    Google::Apis::AnalyticsreportingV4::ReportRow.new(
      dimensions:,
      metrics: metrics.map do |metric|
        Google::Apis::AnalyticsreportingV4::DateRangeValues.new(
          values: Array(metric),
        )
      end,
    )
  end
end
