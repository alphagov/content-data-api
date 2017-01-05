require 'rails_helper'

RSpec.describe GoogleAnalytics::Client do
  describe 'Connecting to the Google Analytics API' do
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
      subject { GoogleAnalytics::Client.new.build }

      it "is an instance of AnalyticsReportingService" do
        expect(subject).to be_kind_of(Google::Apis::AnalyticsreportingV4::AnalyticsReportingService)
      end
    end

    context "when setting up authorization" do
      subject { GoogleAnalytics::Client.new.build }

      it "uses the given client email from the json key" do
        expect(subject.authorization.issuer).to eq(json_key[:client_email])
      end

      it "uses the given private key the json key" do
        expect(subject.authorization.signing_key).to eq(json_key[:private_key])
      end

      it "uses the given scope" do
        options = { scope: "https://scope.com/analytics" }
        auth = GoogleAnalytics::Client.new.build(options)

        expect(auth.authorization.scope).to include("https://scope.com/analytics")
      end

      it "uses read only scope as default, when none is provided" do
        expect(subject.authorization.scope).to include("https://www.googleapis.com/auth/analytics.readonly")
      end
    end
  end
end
