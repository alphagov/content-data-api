RSpec.describe Healthchecks::EtlGoogleAnalytics do
  its(:name) { is_expected.to eq(:etl_google_analytics_pviews) }

  include_examples 'Healthcheck enabled/disabled within time range'

  subject { described_class.build(:pviews) }

  describe "#status" do
    let(:yesterday) { Date.yesterday }

    context 'when there are no metrics' do
      its(:status) { is_expected.to eq(:critical) }
    end

    context 'when there are no pviews for yesterday' do
      before do
        edition = create :edition
        create :metric, edition: edition, date: yesterday, pviews: 0
        create :metric, edition: edition, date: Date.today, pviews: 10
      end

      its(:status) { is_expected.to eq(:critical) }
    end

    context 'when there are pviews for yesterday' do
      before do
        edition = create :edition
        create :metric, edition: edition, date: yesterday, pviews: 10
        create :metric, edition: edition, date: Date.today, pviews: 0
      end

      its(:status) { is_expected.to eq(:ok) }
    end
  end
end
