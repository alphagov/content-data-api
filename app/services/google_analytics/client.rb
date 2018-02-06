require 'google/apis/analyticsreporting_v4'
require 'googleauth'

module GoogleAnalytics
  class Client
    include Google::Apis::AnalyticsreportingV4
    include Google::Auth

    def build(scope: AUTH_ANALYTICS_READONLY)
      @client ||= AnalyticsReportingService.new
      @client.authorization ||= ServiceAccountCredentials.make_creds(scope: scope)
      @client
    end
  end
end
