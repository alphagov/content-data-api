require 'rails_helper'

RSpec.describe Services::GoogleAnalytics do
  describe "interacting with Google Analytics Reporting API" do
    let(:json_key) { { client_email: "test@test.com", private_key: "key" } }

    before do
      path = "/absolute/path/to/key.json"
      @google_auth_credentials = ENV["GOOGLE_AUTH_CREDENTIALS"]
      ENV["GOOGLE_AUTH_CREDENTIALS"] = path

      allow(File).to receive(:open).with(path).and_return(double(File, read: json_key.to_json))
      allow(OpenSSL::PKey::RSA).to receive(:new).and_return(json_key[:private_key])
    end

    after do
      ENV["GOOGLE_AUTH_CREDENTIALS"] = @google_auth_credentials
    end

    it "uses version 4" do
      expect(Google::Apis::AnalyticsreportingV4::VERSION).to eq("V4")
    end

    context "api client" do
      subject { Services::GoogleAnalytics.new.client }

      it "is an instance of AnalyticsReportingService" do
        expect(subject).to be_kind_of(Google::Apis::AnalyticsreportingV4::AnalyticsReportingService)
      end
    end

    context "when setting up authorization" do
      subject { Services::GoogleAnalytics.new.client.authorization }

      it "uses the given client email from the json key" do
        expect(subject.issuer).to eq(json_key[:client_email])
      end

      it "uses the given private key the json key" do
        expect(subject.signing_key).to eq(json_key[:private_key])
      end

      it "uses the given scope" do
        options = { scope: "https://scope.com/analytics" }
        auth = Services::GoogleAnalytics.new.client(options).authorization

        expect(auth.scope).to include("https://scope.com/analytics")
      end

      it "uses read only scope as default, when none is provided" do
        expect(subject.scope).to include("https://www.googleapis.com/auth/analytics.readonly")
      end
    end

    context "pageViews report" do
      let(:page_views_request) do
        {
          report_requests: [
            {
              view_id: "12345678",
              filters_expression: "ga:pagePath==/check-uk-visa",
                metrics: [
                  {
                    expression: "ga:pageViews"
                  }
                ],
              date_ranges: [
                {
                  start_date: "7daysAgo",
                  end_date: "today"
                }
              ]
            }
          ]
        }.with_indifferent_access
      end

      before do
        @cpm_govuk_view_id = ENV["CPM_GOVUK_VIEW_ID"]
        ENV["CPM_GOVUK_VIEW_ID"] = "12345678"
      end

      after do
        ENV["CPM_GOVUK_VIEW_ID"] = @cpm_govuk_view_id
      end

      subject { Services::GoogleAnalytics.new }

      it "builds the requests body with default arguments" do
        built_request = subject.
          build_page_views_body("/check-uk-visa").as_json

        expect(built_request).to include(page_views_request)
      end

      it "builds the requests body with supplied arguments" do
        page_views_request[:report_requests][0][:date_ranges][0][:start_date] = "2016/11/22"
        page_views_request[:report_requests][0][:date_ranges][0][:end_date] = "2016/12/22"

        built_request = subject.build_page_views_body(
          "/check-uk-visa",
          start_date: "2016/11/22",
          end_date: "2016/12/22").as_json

        expect(built_request).to include(page_views_request)
      end
    end
  end
end
