RSpec.describe Etl::GA::Client do
  describe "Connecting to the Google Analytics API" do
    let(:json_key) { { client_email: "test@test.com", private_key: "key" } }

    before do
      @google_private_key = ENV["GOOGLE_PRIVATE_KEY"]
      ENV["GOOGLE_PRIVATE_KEY"] = "key"
      @google_client_email = ENV["GOOGLE_CLIENT_EMAIL"]
      ENV["GOOGLE_CLIENT_EMAIL"] = "test@test.com"
      allow(OpenSSL::PKey::RSA).to receive(:new).and_return("key")
    end

    after do
      ENV["GOOGLE_PRIVATE_KEY"] = @google_private_key
      ENV["GOOGLE_CLIENT_EMAIL"] = @google_client_email
    end

    it "uses version 4" do
      expect(Google::Apis::AnalyticsreportingV4::VERSION).to eq("V4")
    end

    context "api client" do
      subject { Etl::GA::Client.new.build }

      it "is an instance of AnalyticsReportingService" do
        expect(subject).to be_kind_of(Google::Apis::AnalyticsreportingV4::AnalyticsReportingService)
      end
    end

    context "when setting up authorization" do
      subject { Etl::GA::Client.new.build }

      it "uses the given client email from the json key" do
        expect(subject.authorization.issuer).to eq("test@test.com")
      end

      it "uses the given private key the json key" do
        expect(subject.authorization.signing_key).to eq("key")
      end

      it "uses the given scope" do
        options = { scope: "https://scope.com/analytics" }
        auth = Etl::GA::Client.new.build(**options)

        expect(auth.authorization.scope).to include("https://scope.com/analytics")
      end

      it "uses read only scope as default, when none is provided" do
        expect(subject.authorization.scope).to include("https://www.googleapis.com/auth/analytics.readonly")
      end
    end
  end
end
