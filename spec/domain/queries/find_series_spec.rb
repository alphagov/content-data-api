RSpec.describe Queries::FindSeries do
  context "all" do
    it "returns a series of all metrics" do
      create :metric, date: Date.today

      expect(described_class.new.run.length).to eq(17)
    end
  end

  context "between" do
    it "returns metrics for a given date range" do
      edition = create :edition, base_path: '/the/path', date: '2018-5-13'
      create :metric, edition: edition, date: '2018-5-13'
      create :metric, edition: edition, date: '2018-5-14'
      create :metric, edition: edition, date: '2018-5-24'
      series = described_class.new.between(from: '2018-5-13', to: '2018-5-14').run

      expect(series.first.time_series.length).to eq(2)
      expect(series.first.time_series).to eq([
        { date: '2018-05-13', value: 0 },
        { date: '2018-05-14', value: 0 },
      ])
    end
  end

  context "by_metric" do
    it "returns a series of metrics filtered by the passed in metric" do
      create :metric, date: Date.today

      expect(described_class.new.by_metrics(%w[pviews]).run.length).to eq(1)
    end
  end

  context "by_organisation" do
    it "returns a series of metrics filtered by organisation" do
      day0 = Date.new(2018, 1, 12)
      day1 = Date.new(2018, 1, 13)
      day2 = Date.new(2018, 1, 14)
      edition1 = create :edition, date: day0, organisation_id: 'org-1'
      edition2 = create :edition, date: day1, organisation_id: 'org-2'

      create(:metric, edition: edition1, date: day0)
      create(:metric, edition: edition1, date: day1)
      create(:metric, edition: edition2, date: day2)

      series = described_class.new.by_organisation_id('org-1').run

      expect(series.first.time_series).to eq([
        { date: '2018-01-12', value: 0 },
        { date: '2018-01-13', value: 0 },
      ])
    end
  end

  context "by_base_path" do
    it "returns a series of metrics for a base path" do
      day0 = Date.new(2018, 1, 12)
      day1 = Date.new(2018, 1, 13)
      day2 = Date.new(2018, 1, 14)
      edition1 = create(:edition, date: day0, base_path: '/path1')
      edition2 = create(:edition, date: day0, base_path: '/path2')

      create :metric, edition: edition1, date: day0
      create :metric, edition: edition1, date: day1
      create :metric, edition: edition1, date: day2
      create :metric, edition: edition2, date: day1
      create :metric, edition: edition2, date: day2

      result = described_class.new.by_base_path('/path1').run

      expect(result.first.time_series).to eq([
        { date: "2018-01-12", value: 0 },
        { date: "2018-01-13", value: 0 },
        { date: "2018-01-14", value: 0 },
      ])
    end
  end

  describe '#editions' do
    it 'return the content items included in the report' do
      day0 = Date.new(2018, 1, 12)
      day1 = Date.new(2018, 1, 13)
      day2 = Date.new(2018, 1, 14)
      edition1 = create(:edition, base_path: '/path1', date: day0)
      edition2 = create(:edition, base_path: '/path2', date: day0)

      create(:metric, edition: edition1, date: day0)
      create(:metric, edition: edition1, date: day1)
      create(:metric, edition: edition1, date: day2)
      create(:metric, edition: edition2, date: day1)
      create(:metric, edition: edition2, date: day2)

      result = described_class.new.by_base_path('/path1').run
      expect(result.first.time_series).to eq([
        { date: "2018-01-12", value: 0 },
        { date: "2018-01-13", value: 0 },
        { date: "2018-01-14", value: 0 },
      ])
    end
  end
end
