RSpec.describe Queries::FindSeries do
  context "all" do
    it "returns a series of all metrics" do
      create :metric, date: Date.today, pviews: 1

      expect(described_class.new.run.length).to eq(17)
    end
  end

  context "between" do
    it "returns metrics for a given date range" do
      edition = create :edition, base_path: '/the/path', date: '2018-5-13'
      create :metric, edition: edition, date: '2018-5-13', pviews: 1
      create :metric, edition: edition, date: '2018-5-14', pviews: 2
      create :metric, edition: edition, date: '2018-5-24', pviews: 3

      series = described_class.new.by_metrics(%w(pviews)).between(from: '2018-5-13', to: '2018-5-14').run

      expect(series.first.time_series.length).to eq(2)
      expect(series.first.time_series).to eq([
        { date: '2018-05-13', value: 1 },
        { date: '2018-05-14', value: 2 },
      ])
    end
  end

  context "by_metric" do
    it "returns a series of metrics filtered by the passed in metric" do
      create :metric, date: '2018-05-13', pviews: 1

      series = described_class.new.by_metrics(%w(pviews)).run
      expect(series.first.time_series).to eq([
        { date: '2018-05-13', value: 1 },
      ])
    end
  end

  context "by_organisation" do
    it "returns a series of metrics filtered by organisation" do
      edition1 = create :edition, date: '2018-1-12', organisation_id: 'org-1'
      edition2 = create :edition, date: '2018-1-13', organisation_id: 'org-2'

      create :metric, edition: edition1, date: '2018-1-12', pviews: 1
      create :metric, edition: edition1, date: '2018-1-13', pviews: 2
      create :metric, edition: edition2, date: '2018-1-14', pviews: 1

      series = described_class.new.by_metrics(%w(pviews)).by_organisation_id('org-1').run

      expect(series.first.time_series).to eq([
        { date: '2018-01-12', value: 1 },
        { date: '2018-01-13', value: 2 },
      ])
    end
  end

  context "by_base_path" do
    it "returns a series of metrics for a base path" do
      edition1 = create :edition, date: '2018-1-12', base_path: '/path1'
      edition2 = create :edition, date: '2018-1-12', base_path: '/path2'

      create :metric, edition: edition1, date: '2018-1-12', pviews: 1
      create :metric, edition: edition1, date: '2018-1-13', pviews: 2
      create :metric, edition: edition1, date: '2018-1-14', pviews: 3
      create :metric, edition: edition2, date: '2018-1-13', pviews: 4
      create :metric, edition: edition2, date: '2018-1-14', pviews: 5

      result = described_class.new.by_metrics(%w(pviews)).by_base_path('/path1').run

      expect(result.first.time_series).to eq([
        { date: "2018-01-12", value: 1 },
        { date: "2018-01-13", value: 2 },
        { date: "2018-01-14", value: 3 },
      ])
    end
  end

  describe '#editions' do
    it 'return the content items included in the report' do
      edition1 = create :edition, base_path: '/path1', date: '2018-1-12'
      edition2 = create :edition, base_path: '/path2', date: '2018-1-12'

      create :metric, edition: edition1, date: '2018-1-12', pviews: 1
      create :metric, edition: edition1, date: '2018-1-13', pviews: 2
      create :metric, edition: edition1, date: '2018-1-14', pviews: 4
      create :metric, edition: edition2, date: '2018-1-13', pviews: 5
      create :metric, edition: edition2, date: '2018-1-14', pviews: 6

      result = described_class.new.by_metrics(%w(pviews)).by_base_path('/path1').run
      expect(result.first.time_series).to eq([
        { date: "2018-01-12", value: 1 },
        { date: "2018-01-13", value: 2 },
        { date: "2018-01-14", value: 4 },
      ])
    end
  end
end
