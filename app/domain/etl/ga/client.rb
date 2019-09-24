require "google/apis/analyticsreporting_v4"
require "googleauth"

class Etl::GA::Client
  include Google::Apis::AnalyticsreportingV4
  include Google::Auth

  def self.build
    new.build
  end

  def build(scope: AUTH_ANALYTICS_READONLY)
    @client ||= AnalyticsReportingService.new
    @client.authorization ||= ServiceAccountCredentials.make_creds(scope: scope)
    @client
  end
end
