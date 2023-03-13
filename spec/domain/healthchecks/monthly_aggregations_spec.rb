RSpec.describe Healthchecks::MonthlyAggregations do
  include_examples "Healthcheck enabled/disabled within time range"

  around do |example|
    Timecop.freeze(Time.zone.local(2019, 2, 22, 14, 0)) { example.run }
  end

  its(:name) { is_expected.to eq(:aggregations) }

  describe "#status" do
    context "When there are monthly aggregations" do
      before do
        date = Time.zone.today
        edition = create :edition
        create :monthly_metric, edition:, month: Dimensions::Month.build(date).id
      end

      its(:status) { is_expected.to eq(:ok) }
      its(:message) { is_expected.to eq(nil) }
    end

    context "When there are no aggregations" do
      its(:status) { is_expected.to eq(:critical) }
    end
  end
end
