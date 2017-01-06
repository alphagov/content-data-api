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
      before do
        @cpm_govuk_view_id = ENV["CPM_GOVUK_VIEW_ID"]
        ENV["CPM_GOVUK_VIEW_ID"] = "12345678"
      end

      after do
        ENV["CPM_GOVUK_VIEW_ID"] = @cpm_govuk_view_id
      end

      subject { GoogleAnalyticsService.new }

      it "raises an exception when another type is supplied, instead of an Array" do
        expect { subject.page_views("/marriage-abroad") }.to raise_error("base_paths isn't an array")
      end
    end
  end
end
