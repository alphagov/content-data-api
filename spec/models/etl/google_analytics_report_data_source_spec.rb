require 'rails_helper'

RSpec.describe ETL::GoogleAnalyticsReportDataSource do
  subject(:source) do
    described_class.new(
      reporting_service: reporting_service,
      date: Date.today,
    )
  end

  let(:reporting_service) do
    instance_double(
      'Google::Apis::AnalyticsreportingV4::AnalyticsReportingService'
    )
  end

  describe '#each' do
    before do
      allow(reporting_service).to receive(:fetch_all) do
        [
          build_report_data(
            build_report_row(dimensions: %w(/foo), metrics: %w(1 1))
          ),
          build_report_data(
            build_report_row(dimensions: %w(/bar), metrics: %w(2 2))
          ),
        ]
      end
    end

    context 'when called without a block' do
      subject { source.each }

      it { is_expected.to be_a_kind_of(Enumerator) }
    end

    context 'when called with a block' do
      it 'should yield successive report data' do
        expected_report_data = [
          a_hash_including(
            'ga:pagePath' => '/foo',
            'ga:pageviews' => 1,
            'ga:uniquePageviews' => 1
          ),
          a_hash_including(
            'ga:pagePath' => '/bar',
            'ga:pageviews' => 2,
            'ga:uniquePageviews' => 2
          ),
        ]

        expect { |probe| source.each(&probe) }
          .to yield_successive_args(*expected_report_data)
      end
    end
  end

private

  def build_report_data(*report_rows)
    Google::Apis::AnalyticsreportingV4::ReportData.new(rows: report_rows)
  end

  def build_report_row(dimensions:, metrics:)
    Google::Apis::AnalyticsreportingV4::ReportRow.new(
      dimensions: dimensions,
      metrics: metrics.map do |metric|
        Google::Apis::AnalyticsreportingV4::DateRangeValues.new(
          values: Array(metric)
        )
      end
    )
  end
end
