require 'rails_helper'

RSpec.describe ETL::GoogleAnalyticsReportDataJob, type: :job do
  let(:year) { 2018 }
  let(:month) { 1 }
  let(:day) { 1 }

  it { is_expected.to be_processed_in(:google_analytics) }

  it 'enqueues a job with additional metadata' do
    described_class.perform_async(year, month, day)

    expect(described_class).to have_enqueued_sidekiq_job(
      year, month, day, authenticated_user: nil, request_id: nil
    )
  end
end
