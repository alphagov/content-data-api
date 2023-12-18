RSpec.describe Facts::Metric, type: :model do
  it { is_expected.to validate_presence_of(:dimensions_date) }
  it { is_expected.to validate_presence_of(:dimensions_edition) }

  describe ".for_two_days_ago" do
    around do |example|
      Timecop.freeze(Date.new(2018, 1, 15)) { example.run }
    end

    it "returns metrics for day before yesterday" do
      metric1 = create :metric, date: "2018-01-13"
      metric2 = create :metric, date: "2018-01-13"
      create :metric, date: "2018-01-12"

      expect(Facts::Metric.for_2_days_ago).to match_array([metric1, metric2])
    end
  end

  describe ".from_two_days_ago" do
    around do |example|
      Timecop.freeze(Date.new(2018, 1, 13)) { example.run }
    end

    it "returns a previous date's metrics" do
      date = Date.new(2018, 1, 13)
      metric1 = create :metric, date: "2018-01-12"
      metric2 = create :metric, date: "2018-01-11"
      create :metric, date: "2018-01-10"

      expect(Facts::Metric.from_day_before_to(date)).to match_array([metric1, metric2])
    end
  end
end
