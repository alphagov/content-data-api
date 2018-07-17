RSpec.describe Etl::Item::Quality::Service do
  include QualityMetricsHelpers
  subject { described_class.new }
  context 'when the service return non 200 response' do
    before do
      stub_failing_quality_metrics(status: 500, body: 'the error')
    end

    it 'raises a QualityMetricsError' do
      expect { subject.run('some content') }.to raise_error(QualityMetricsError, 'response body: the error')
    end
  end
end
