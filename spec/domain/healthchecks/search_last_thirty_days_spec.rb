RSpec.describe Healthchecks::SearchLastThirtyDays do
  include_examples 'Healthcheck enabled/disabled within time range'

  its(:name) { is_expected.to eq(:search_last_thirty_days) }

  describe 'status' do
    let!(:primary_org_id) { '96cad973-92dc-41ea-a0ff-c377908fee74' }
    let!(:edition) { create :edition, base_path: '/path1', date: 2.months.ago, organisation_id: primary_org_id }
    let!(:metric1) { create :metric, edition: edition, date: 15.days.ago, upviews: 15, useful_yes: 8, useful_no: 9, searches: 10 }
    let!(:metric2) { create :metric, edition: edition, date: 10.days.ago, upviews: 20, useful_yes: 5, useful_no: 1, searches: 1 }

    context 'When there are search views for the last thirty days' do
      before do
        ::Aggregations::SearchLastThirtyDays.refresh
      end

      its(:status) { is_expected.to eq(:ok) }
      its(:message) { is_expected.to eq(nil) }
    end

    context 'There are no search views for the last 30 days' do
      its(:status) { is_expected.to eq(:critical) }
      its(:message) { is_expected.to eq('ETL :: no last 30 days aggregations for searches updated from yesterday') }
    end
  end
end
