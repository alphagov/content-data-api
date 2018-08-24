RSpec.describe Facts::Metric, type: :model do
  include ItemSetupHelpers

  it { is_expected.to validate_presence_of(:dimensions_date) }
  it { is_expected.to validate_presence_of(:dimensions_item) }

  describe '.satisfaction_score' do
    it 'calculates and sets satisfaction_score with yes and no values' do
      metric = FactoryBot.build :metric, is_this_useful_yes: 10, is_this_useful_no: 2

      expect(metric.satisfaction_score).to eq(10.to_f / (10 + 2).to_f)
      expect(metric.satisfaction_score.round(2)).to eq(0.83)
    end

    it 'sets satisfaction_score to `nil` with `no` values' do
      metric = FactoryBot.build :metric

      expect(metric.satisfaction_score).to be_nil
    end

    it 'sets satisfaction_score to `nil` with explicit `nil` values' do
      metric = FactoryBot.build :metric, is_this_useful_yes: nil, is_this_useful_no: nil

      expect(metric.satisfaction_score).to be_nil
    end

    it 'sets satisfaction_score 100% with only `yes` values and no `no` values' do
      metric = FactoryBot.build :metric, is_this_useful_yes: 1

      expect(metric.satisfaction_score).to eq(1)
    end

    it 'sets satisfaction_score 100% with a `yes` value and `no` value explicitly set to `0`' do
      metric = FactoryBot.build :metric, is_this_useful_yes: 1, is_this_useful_no: 0

      expect(metric.satisfaction_score).to eq(1)
    end

    it 'sets satisfaction_score 100% with a `yes` value and `no` value explicitly set to `nil`' do
      metric = FactoryBot.build :metric, is_this_useful_yes: 1, is_this_useful_no: nil

      expect(metric.satisfaction_score).to eq(1)
    end

    it 'sets satisfaction_score to 0% with only `no` values' do
      metric = FactoryBot.build :metric, is_this_useful_no: 1

      expect(metric.satisfaction_score).to eq(0)
    end

    it 'sets satisfaction_score to 0% with a `no` value and `yes` value explicitly set to `0`' do
      metric = FactoryBot.build :metric, is_this_useful_no: 1, is_this_useful_yes: 0

      expect(metric.satisfaction_score).to eq(0)
    end

    it 'sets satisfaction_score to 0% with no `no` value and `yes` value explicitly set to `0`' do
      metric = FactoryBot.build :metric, is_this_useful_yes: 0

      expect(metric.satisfaction_score).to eq(0)
    end

    it 'sets satisfaction_score to 0% with only no values and yes explicitly set to nil' do
      metric = FactoryBot.build :metric, is_this_useful_yes: nil, is_this_useful_no: 1

      expect(metric.satisfaction_score).to eq(0)
    end

    it 'recalculates satisfaction_score when `no` is updated' do
      metric = FactoryBot.build :metric, is_this_useful_yes: 1
      expect(metric.satisfaction_score).to eq(1)

      metric.is_this_useful_no = 1
      expect(metric.satisfaction_score).to eq(0.5)
    end

    it 'recalculates satisfaction_score when `yes` is updated' do
      metric = FactoryBot.build :metric, is_this_useful_no: 1
      expect(metric.satisfaction_score).to eq(0)

      metric.is_this_useful_yes = 1
      expect(metric.satisfaction_score).to eq(0.5)
    end
  end

  describe ".for_yesterday" do
    around do |example|
      Timecop.freeze(Date.new(2018, 1, 15)) { example.run }
    end

    it "returns yesterday's metrics" do
      metric1 = create_metric base_path: '/path1', date: '2018-01-14'
      metric2 = create_metric base_path: '/path2', date: '2018-01-14'
      create_metric base_path: '/path2', date: '2018-01-13'

      expect(Facts::Metric.for_yesterday).to match_array([metric1, metric2])
    end
  end
end
