RSpec.describe Etl::GA::Bigquery do
  describe "Connecting to the Google Cloud BigQuery API" do
    let(:json_key) { { client_email: "test@test.com", private_key: "key" } }

    before do
      stub_request(:post, "https://oauth2.googleapis.com/token").
        to_return(status: 200, body: "{}", headers: { 'Content-Type' => 'application/json' })

      @bigquery_project = ENV["BIGQUERY_PROJECT"]
      ENV["BIGQUERY_PROJECT"] = "bigquery-project-123"
      @bigquery_credentials = ENV["BIGQUERY_CREDENTIALS"]

      temp_file = Tempfile.new("keyfile.json")
      temp_file.write(json_key.to_json)
      temp_file.close
      ENV["BIGQUERY_CREDENTIALS"] = temp_file.path

      allow(OpenSSL::PKey::RSA).to receive(:new).and_return("key")
    end

    after do
      ENV["BIGQUERY_CREDENTIALS"] = @bigquery_credentials
      ENV["BIGQUERY_PROJECT"] = @bigquery_project
    end

    context "api client" do
      subject { Etl::GA::Bigquery.new.build }

      it "is an instance of Google::Cloud::Bigquery::Project" do
        expect(subject).to be_a(Google::Cloud::Bigquery::Project)
      end
    end

    context "when setting up authorization" do
      subject { Etl::GA::Bigquery.new.build }

      it "uses the given client email from the json key" do
        binding.pry
        expect(subject.authorization.issuer).to eq("test@test.com")
      end

      it "uses the given private key the json key" do
        expect(subject.authorization.signing_key).to eq("key")
      end

      it "uses the given scope" do
        options = { scope: "https://www.googleapis.com/auth/bigquery" }
        auth = Etl::GA::Client.new.build

        expect(auth.authorization.scope).to include("https://www.googleapis.com/auth/bigquery")
      end

      # it "raises an error if credentials are not set" do
      # end
    end

    # context "when the query is valid" do
    #   subject { Etl::GA::Bigquery.new.build }

    #   it "returns the correct data" do
    #     expect(subject.get_data(query = "SELECT * FROM table")).to eq(expected_data)
    #   end

    #   it "returns the correct data with a column name" do
    #     query = <<~SQL
    #       SELECT *
    #       FROM `your-project-id.#{@bigquery_project}.your-table-id`
    #       LIMIT 10
    #     SQL
 
    #     results = bigquery.query(query)
 
    #     expect(results.count).to eq(10)
    #     expect(results.first.keys).to include("column_name")
    # end
    # context "when the query is invalid" do
    #   it "raises an error" do
    #     expect { subject.get_data(query = "INVALID QUERY") }.to raise_error(BigQueryError)
    #   end
    # end
  end
end
