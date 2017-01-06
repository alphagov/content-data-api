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

    request_body = GoogleAnalytics::Requests::PageViewsRequest.new.build(base_paths)
    data = client.batch_get_reports(request_body).reports[0].data

    data.rows.inject({}) do |page_views, row|
      page_views[row.dimensions[0]] = row.metrics[0].values[0].to_i
      page_views
    end
  end
end
