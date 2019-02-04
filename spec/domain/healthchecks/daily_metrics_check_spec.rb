RSpec.describe Healthchecks::DailyMetricsCheck do
  let(:today) { Time.new(2018, 1, 15, 16, 0, 0) }

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

  describe '#enabled?' do
    context 'before 9:30 am' do
      let (:today) { Time.new(2018, 1, 15, 9, 29, 0) }

      it { is_expected.to_not be_enabled}
    end

    context 'after 9:30 am' do
      let (:today) { Time.new(2018, 1, 15, 9, 31, 0) }

      it { is_expected.to be_enabled}
    end
  end
end
