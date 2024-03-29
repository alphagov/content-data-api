RSpec.describe Etl::GA::Bigquery do
  describe "Connecting to the Google Cloud BigQuery API" do
    before do
      stub_request(:post, "https://www.googleapis.com/oauth2/v4/token")
      .to_return(status: 200, body: "{}", headers: { "Content-Type" => "application/json" })

      ENV["BIGQUERY_PROJECT"] = "bigquery-project-123"
      ENV["BIGQUERY_CLIENT_EMAIL"] = "test@test.com"
      ENV["BIGQUERY_PRIVATE_KEY"] = "key"

      allow(OpenSSL::PKey::RSA).to receive(:new).and_return("key")
    end

    context "api client" do
      subject { Etl::GA::Bigquery.new.build }

      it "is an instance of Google::Cloud::Bigquery::Project" do
        expect(subject).to be_kind_of(Google::Cloud::Bigquery::Project)
      end
    end

    context "when setting up authorization" do
      subject { Etl::GA::Bigquery.new.build }

      it "uses the given client email from the JSON contents" do
        expect(subject.service.credentials.issuer).to eq("test@test.com")
      end

      it "uses the given private key from the JSON contents" do
        expect(subject.service.credentials.signing_key).to eq("key")
      end

      it "uses the BigQuery scope" do
        expect(subject.service.credentials.scope).to include("https://www.googleapis.com/auth/bigquery")
      end

      it "raises an error if the project_id is not set" do
        ENV["BIGQUERY_PROJECT"] = ""

        expect { Etl::GA::Bigquery.new.build }.to raise_error(ArgumentError, "project_id is missing")
      end
    end
  end
end
