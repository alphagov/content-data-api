RSpec.describe Finders::SelectView do
  let(:primary_org_id) { "96cad973-92dc-41ea-a0ff-c377908fee74" }

  describe "#select_view" do
    it "returns last 30 days view if date range is `past-30-days`" do
      expect(described_class.new("past-30-days").run).to eq(model_name: Aggregations::SearchLastThirtyDays, table_name: "last_thirty_days")
    end

    it "returns last month view if date range is `last-month`" do
      expect(described_class.new("last-month").run).to eq(model_name: Aggregations::SearchLastMonth, table_name: "last_months")
    end

    it "returns last 3 months view if date range is `past-3-months`" do
      expect(described_class.new("past-3-months").run).to eq(model_name: Aggregations::SearchLastThreeMonths, table_name: "last_three_months")
    end

    it "returns last 6 months view if date range is `past-6-months`" do
      expect(described_class.new("past-6-months").run).to eq(model_name: Aggregations::SearchLastSixMonths, table_name: "last_six_months")
    end

    it "returns last year view if date range is `past-year`" do
      expect(described_class.new("past-year").run).to eq(model_name: Aggregations::SearchLastTwelveMonths, table_name: "last_twelve_months")
    end

    it "returns a specific month if the date range is a valid specified month" do
      expect(described_class.new("november-2019").run).to eq(model_name: Aggregations::MonthlyMetric, table_name: "aggregations_monthly_metrics")
    end
  end
end
