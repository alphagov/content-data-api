require 'google/apis/analyticsreporting_v4'
require 'googleauth'

module Services
  class GoogleAnalytics
    include Google::Apis::AnalyticsreportingV4
    include Google::Auth

    def client(scope: "https://www.googleapis.com/auth/analytics.readonly")
      @client ||= AnalyticsReportingService.new
      @client.authorization ||= ServiceAccountCredentials.make_creds(
        json_key_io: File.open(ENV["GOOGLE_AUTH_CREDENTIALS"]),
        scope: scope
      )
      @client
    end
  end
end
