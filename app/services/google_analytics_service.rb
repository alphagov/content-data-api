class GoogleAnalyticsService
  def client
    @client ||= GoogleAnalytics::Client.new.build
  end

  def page_views(base_paths)
    raise "base_paths isn't an array" unless base_paths.is_a?(Array)

    request = GoogleAnalytics::Requests::PageViewsRequest.new.build(base_paths)
    response = client.batch_get_reports(request)
    GoogleAnalytics::Responses::PageViewsResponse.new.parse(response)
  end
end
