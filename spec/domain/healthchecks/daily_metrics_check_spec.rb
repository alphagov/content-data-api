RSpec.describe Healthchecks::DailyMetricsCheck do
  let(:today) { Date.new(2018, 1, 15) }

  around do |example|
    Timecop.freeze(today) { example.run }
  end

  context 'When there are metrics' do
    before { create :metric, dimensions_date: Dimensions::Date.for(Date.yesterday) }

    it 'returns status :ok' do
      expect(subject.status).to eq(:ok)
    end

    it 'returns a detailed message' do
      expect(subject.message).to eq('There are 1 metrics for 2018-01-14')
    end
  end

  context 'When there are no metrics' do
    it 'returns status :critical' do
      expect(subject.status).to eq(:critical)
    end

    it 'returns a detailed message' do
      expect(subject.message).to eq('There are 0 metrics for 2018-01-14')
    end
  end
end
