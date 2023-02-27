RSpec.describe Healthchecks::EtlMetricValues do
  its(:name) { is_expected.to eq(:etl_metric_values_pviews) }

  include_examples "Healthcheck enabled/disabled within time range"

  subject { described_class.build(:pviews) }

  let(:yesterday) { Date.yesterday }

  context "when there are no pviews for yesterday" do
    before do
      edition = create :edition
      create :metric, edition:, date: yesterday, pviews: 0
      create :metric, edition:, date: Time.zone.today, pviews: 10
    end

    its(:status) { is_expected.to eq(:critical) }
    its(:message) { is_expected.to eq("ETL :: no pviews for yesterday") }
  end

  context "when there are pviews for yesterday" do
    before do
      edition = create :edition
      create :metric, edition:, date: yesterday, pviews: 10
      create :metric, edition:, date: Time.zone.today, pviews: 10
    end

    its(:status) { is_expected.to eq(:ok) }
    its(:message) { is_expected.to be_nil }
  end
end
