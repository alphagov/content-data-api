require 'google/apis/analyticsreporting_v4'
require 'googleauth'

class GoogleAnalyticsService
  include Google::Apis::AnalyticsreportingV4
  include Google::Auth

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
