RSpec.describe Reports::FindSeries do
  context "all" do
    it "returns a series of all metrics" do
      create :metric, date: Date.today

      expect(described_class.new.run.one?).to eq(true)
    end
  end

  context "between" do
    it "returns metrics for a given date range" do
      edition = create :edition, base_path: '/the/path', date: '2018-5-13'
      metric1 = create :metric, edition: edition, date: '2018-5-13'
      metric2 = create :metric, edition: edition, date: '2018-5-14'
      create :metric, edition: edition, date: '2018-5-24'
      series = described_class.new.between(from: '2018-5-13', to: '2018-5-14').run

      expect(series).to_not be_nil
      expect(series.size).to eq(2)
      expect(series).to match_array([metric1, metric2])
    end
  end

  context "by_metric" do
    it "returns a series of metrics filtered by the passed in metric" do
      today = Date.today
      tomorrow = today + 1

      edition1 = create :edition, base_path: '/path/1', date: today, facts: { words: 10_000 }
      metric1 = create :metric, date: today, edition: edition1
      edition2 = create :edition, base_path: '/path/2', date: tomorrow, facts: { words: 20_000 }
      metric2 = create :metric, date: tomorrow, edition: edition2
      metric3 = create :metric, date: tomorrow

      series = described_class.new.run

      expect(series).to match_array([metric1, metric2, metric3])
    end
  end

  context "by_organisation" do
    it "returns a series of metrics filtered by organisation" do
      day0 = Date.new(2018, 1, 12)
      day1 = Date.new(2018, 1, 13)
      day2 = Date.new(2018, 1, 14)
      edition1 = create :edition, date: day0, organisation_id: 'org-1'
      edition2 = create :edition, date: day1, organisation_id: 'org-2'

      metric1 = create(:metric, edition: edition1, date: day0)
      metric2 = create(:metric, edition: edition1, date: day1)
      create(:metric, edition: edition2, date: day2)

      series = described_class.new.by_organisation_id('org-1').run

      expect(series).to match_array([metric1, metric2])
    end

    it 'ignores parameters when blank' do
      metric = create(:metric, date: Date.today)

      expect(described_class.new.by_organisation_id('').run).to match_array([metric])
    end
  end

  context "by_base_path" do
    it "returns a series of metrics for a base path" do
      day0 = Date.new(2018, 1, 12)
      day1 = Date.new(2018, 1, 13)
      day2 = Date.new(2018, 1, 14)
      edition1 = create(:edition, date: day0, base_path: '/path1')
      edition2 = create(:edition, date: day0, base_path: '/path2')

      metric1 = create :metric, edition: edition1, date: day0
      metric2 = create :metric, edition: edition1, date: day1
      metric3 = create :metric, edition: edition1, date: day2
      create :metric, edition: edition2, date: day1
      create :metric, edition: edition2, date: day2

      results = described_class.new.by_base_path('/path1').run

      expect(results).to match_array([metric1, metric2, metric3])
    end

    it 'ignores parameters when blank' do
      metric = create(:metric, date: Date.today)

      expect(described_class.new.by_base_path('').run).to match_array([metric])
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

      expect(described_class.new.editions).to match_array([edition1, edition2])
    end
  end
end
