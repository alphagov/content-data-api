RSpec.describe Healthchecks::DailyMetricsCheck do
  include_examples "Healthcheck enabled/disabled within time range"

  describe "#status" do
    context "When there are metrics" do
      before { create :metric, dimensions_date: Dimensions::Date.build(Time.zone.today - 2) }

      it "returns status :ok" do
        expect(subject.status).to eq(:ok)
      end
    end

    context "When there are no metrics" do
      it "returns status :critical" do
        expect(subject.status).to eq(:critical)
      end

      it "returns a detailed message" do
        expect(subject.message).to eq("ETL :: no daily metrics for day before yesterday")
      end
    end
  end
end
