class GoogleAnalyticsService
  def client
    @client ||= GoogleAnalytics::Client.new.build
  end

  def one_and_six_month_pageviews(base_paths)
    raise "base_paths isn't an array" unless base_paths.is_a?(Array)
    base_paths = base_paths.select(&:present?)
    return [] if base_paths.empty?

    request = GoogleAnalytics::Requests::PageViewsRequest.new.build(
      base_paths: base_paths,
      start_dates: [1.month.ago.strftime("%Y-%m-%d"), 6.months.ago.strftime("%Y-%m-%d")]
    )
    response = client.batch_get_reports(request)
    GoogleAnalytics::Responses::OneAndSixMonthPageviewsResponse.new.parse(response)
  end
end
