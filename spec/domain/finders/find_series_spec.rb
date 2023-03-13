RSpec.describe Finders::FindSeries do
  context "all" do
    it "returns a series of all metrics" do
      create :metric, date: Time.zone.today, pviews: 1

      expect(described_class.new.run.length).to eq(16)
    end
  end

  context "between" do
    it "returns metrics for a given date range" do
      edition = create :edition, base_path: "/the/path", date: "2018-5-13"
      create :metric, edition:, date: "2018-5-13", pviews: 1
      create :metric, edition:, date: "2018-5-14", pviews: 2
      create :metric, edition:, date: "2018-5-24", pviews: 3

      series = described_class.new.between(from: "2018-5-13", to: "2018-5-14").run

      expect(series.first.time_series).to contain_exactly(
        include(date: "2018-05-13"),
        include(date: "2018-05-14"),
      )
    end
  end

  context "by_warehouse_item_id" do
    it "returns a series of metrics for a base path" do
      edition1 = create :edition, date: "2018-1-12"
      edition2 = create :edition, date: "2018-1-12"

      create :metric, edition: edition1, date: "2018-1-12", pviews: 1
      create :metric, edition: edition1, date: "2018-1-13", pviews: 2
      create :metric, edition: edition1, date: "2018-1-14", pviews: 3
      create :metric, edition: edition2, date: "2018-1-13", pviews: 4
      create :metric, edition: edition2, date: "2018-1-14", pviews: 5

      series = described_class.new
        .by_warehouse_item_id(edition1.warehouse_item_id)
        .run

      pageviews = series.find { |s| s.metric_name == "pviews" }

      expect(pageviews.time_series).to contain_exactly(
        include(date: "2018-01-12", value: 1),
        include(date: "2018-01-13", value: 2),
        include(date: "2018-01-14", value: 3),
      )
    end
  end

  describe "#editions" do
    it "return the content items included in the report" do
      edition1 = create :edition, base_path: "/path1", date: "2018-1-12", facts: { words: 1 }
      edition2 = create :edition, base_path: "/path2", date: "2018-1-12", facts: { words: 2 }

      create :metric, edition: edition1, date: "2018-1-12"
      create :metric, edition: edition1, date: "2018-1-13"
      create :metric, edition: edition1, date: "2018-1-14"
      create :metric, edition: edition2, date: "2018-1-13"
      create :metric, edition: edition2, date: "2018-1-14"

      series = described_class.new.run

      words = series.find { |s| s.metric_name == "words" }

      expect(words.time_series).to contain_exactly(
        include(date: "2018-01-12", value: 1),
        include(date: "2018-01-13", value: 1),
        include(date: "2018-01-13", value: 2),
        include(date: "2018-01-14", value: 1),
        include(date: "2018-01-14", value: 2),
      )
    end
  end
end
