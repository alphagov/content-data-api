RSpec.describe Healthchecks::SearchAggregations do
  include AggregationsSupport
  include_examples "Healthcheck enabled/disabled within time range"

  let(:subject) { described_class.build(:last_month) }

  its(:name) { is_expected.to eq(:search_last_month) }

  describe "status" do
    let!(:primary_org_id) { "96cad973-92dc-41ea-a0ff-c377908fee74" }
    let!(:edition) { create :edition, primary_organisation_id: primary_org_id }

    context "When there are search views for the last thirty days" do
      before do
        create :metric, edition:, date: Time.zone.today.last_month.beginning_of_month
        create :metric, edition:, date: Time.zone.today.last_month.end_of_month

        recalculate_aggregations!
      end

      its(:status) { is_expected.to eq(:ok) }
      its(:message) { is_expected.to eq(nil) }
    end

    context "There are no search views for the last month" do
      before do
        recalculate_aggregations!
      end

      its(:status) { is_expected.to eq(:critical) }
      its(:message) { is_expected.to eq("ETL :: no Last month searches updated from yesterday") }
    end
  end
end
