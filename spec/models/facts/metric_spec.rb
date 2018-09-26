RSpec.describe Facts::Metric, type: :model do
  include ItemSetupHelpers

  it { is_expected.to validate_presence_of(:dimensions_date) }
  it { is_expected.to validate_presence_of(:dimensions_item) }

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

  describe ".from_yesterday" do
    around do |example|
      Timecop.freeze(Date.new(2018, 1, 13)) { example.run }
    end

    it "returns a previous date's metrics" do
      date = Date.new(2018, 1, 13)
      metric1 = create_metric base_path: '/path1', date: '2018-01-13'
      metric2 = create_metric base_path: '/path2', date: '2018-01-12'
      create_metric base_path: '/path2', date: '2018-01-11'

      expect(Facts::Metric.from_day_before_to(date)).to match_array([metric1, metric2])
    end
  end
end
