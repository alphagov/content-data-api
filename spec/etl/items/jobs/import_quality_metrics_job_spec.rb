RSpec.describe Items::Jobs::ImportQualityMetricsJob do
  it 'raises an error and records it in Sentry if importer errors' do
    allow(Items::Importers::QualityMetrics).to receive(:run).and_raise(StandardError)
    expect(GovukError).to receive(:notify)
    expect { subject.run }.to raise_error
  end
end
