require 'rails_helper'

RSpec.describe GoogleAnalyticsService do
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

    context "pageViews report" do
      let(:page_views_response) do
        Google::Apis::AnalyticsreportingV4::GetReportsResponse.new(
          reports: [
            Google::Apis::AnalyticsreportingV4::Report.new(
              data: Google::Apis::AnalyticsreportingV4::ReportData.new(
                rows: [
                  Google::Apis::AnalyticsreportingV4::ReportRow.new(
                    dimensions: ["/check-uk-visa"],
                    metrics: [
                      Google::Apis::AnalyticsreportingV4::DateRangeValues.new(
                        values: [
                          "400"
                        ]
                      )
                    ]
                  )
                ]
              )
            )
          ]
        )
      end

      let(:two_page_views_response) do
        Google::Apis::AnalyticsreportingV4::GetReportsResponse.new(
          reports: [
            Google::Apis::AnalyticsreportingV4::Report.new(
              data: Google::Apis::AnalyticsreportingV4::ReportData.new(
                rows: [
                  Google::Apis::AnalyticsreportingV4::ReportRow.new(
                    dimensions: ["/check-uk-visa"],
                    metrics: [
                      Google::Apis::AnalyticsreportingV4::DateRangeValues.new(
                        values: [
                          "400"
                        ]
                      )
                    ]
                  ),
                  Google::Apis::AnalyticsreportingV4::ReportRow.new(
                    dimensions: ["/marriage-abroad"],
                    metrics: [
                      Google::Apis::AnalyticsreportingV4::DateRangeValues.new(
                        values: [
                          "500"
                        ]
                      )
                    ]
                  )
                ]
              )
            )
          ]
        )
      end

      before do
        @cpm_govuk_view_id = ENV["CPM_GOVUK_VIEW_ID"]
        ENV["CPM_GOVUK_VIEW_ID"] = "12345678"
      end

      after do
        ENV["CPM_GOVUK_VIEW_ID"] = @cpm_govuk_view_id
      end

      subject { GoogleAnalyticsService.new }

      it "returns the number of page views for a content item" do
        base_path_views = { "/check-uk-visa" => 400 }.with_indifferent_access
        allow(subject.client)
          .to receive(:batch_get_reports).and_return(page_views_response)
        page_views = subject.page_views(["/check-uk-visa"])

        expect(page_views).to include(base_path_views)
        expect(page_views["/check-uk-visa"]).to eq(400)
      end

      it "returns the number of page views for content items" do
        base_paths = ["/check-uk-visa", "/marriage-abroad"]
        allow(subject.client)
          .to receive(:batch_get_reports).and_return(two_page_views_response)
        page_views = subject.page_views(base_paths)

        expect(page_views.keys).to match_array(base_paths)
        expect(page_views.values).to match_array([400, 500])
      end

      it "raises an exception when another type is supplied, instead of an Array" do
        allow(subject.client)
          .to receive(:batch_get_reports).and_return(two_page_views_response)

        expect { subject.page_views("/marriage-abroad") }.to raise_error("base_paths isn't an array")
      end
    end
  end
end
