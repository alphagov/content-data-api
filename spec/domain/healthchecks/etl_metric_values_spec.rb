RSpec.describe Healthchecks::EtlMetricValues do
  its(:name) { is_expected.to eq(:etl_metric_values_pviews) }

  include_examples "Healthcheck enabled/disabled within time range"

  subject { described_class.build(:pviews) }

  let(:two_days_ago) { Time.zone.today - 2 }

  context "when there are no pviews for day before yesterday" do
    before do
      edition = create :edition
      create :metric, edition:, date: two_days_ago, pviews: 0
      create :metric, edition:, date: Time.zone.today - 3, pviews: 10
    end

    its(:status) { is_expected.to eq(:critical) }
    its(:message) { is_expected.to eq("ETL :: no pviews for day before yesterday") }
  end

  context "when there are pviews for day before yesterday" do
    before do
      edition = create :edition
      create :metric, edition:, date: two_days_ago, pviews: 10
      create :metric, edition:, date: Time.zone.today - 3, pviews: 10
    end

    its(:status) { is_expected.to eq(:ok) }
    its(:message) { is_expected.to be_nil }
  end
end
