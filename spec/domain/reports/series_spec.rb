
RSpec.describe Reports::Series do
  context "all" do
    it "returns a series of all metrics" do
      item = create(:dimensions_item)
      create(:metric, dimensions_item: item)
      described_class.new.for_en

      expect(described_class.new.for_en.run.one?).to eq(true)
    end
  end

  context "between" do
    it "returns metrics for a given date range" do
      date_from = Dimensions::Date.for(Date.new(2018, 5, 13))
      date_to = Dimensions::Date.for(Date.new(2018, 5, 14))
      metric1 = create(:metric, dimensions_date: date_from)
      metric2 = create(:metric, dimensions_date: date_to)
      create(:metric, dimensions_date: Dimensions::Date.for(Date.new(2018, 5, 24)))
      series = described_class.new.between(from: date_from, to: date_to).run

      expect(series).to_not be_nil
      expect(series.size).to eq(2)
      expect(series).to match_array([metric1, metric2])
    end
  end

  context "by_metric" do
    it "returns a series of metrics filtered by the passed in metric" do
      item1 = create(:dimensions_item)
      today = Dimensions::Date.for(Date.today)
      create(
        :facts_edition,
        dimensions_item: item1,
        dimensions_date: today,
        word_count: 10_000
      )

      item2 = create(:dimensions_item)
      tomorrow = Dimensions::Date.for(Date.today + 1)
      create(
        :facts_edition,
        dimensions_item: item2,
        dimensions_date: tomorrow,
        word_count: 20_000
      )

      item3 = create(:dimensions_item)
      tomorrow = Dimensions::Date.for(Date.today + 1)
      create(
        :facts_edition,
        dimensions_item: item3,
        dimensions_date: tomorrow
      )

      metric1 = create(:metric, dimensions_item: item1, dimensions_date: today)
      metric2 = create(:metric, dimensions_item: item2, dimensions_date: tomorrow)
      metric3 = create(:metric, dimensions_item: item3, dimensions_date: tomorrow)

      series = described_class.new.with_edition_metrics.run

      expect(series).to match_array([metric1, metric2, metric3])
    end
  end

  context "by_organisation" do
    it "returns a series of metrics filtered by organisation" do
      day0 = create(:dimensions_date, date: Date.new(2018, 1, 12))
      day1 = create(:dimensions_date, date: Date.new(2018, 1, 13))
      day2 = create(:dimensions_date, date: Date.new(2018, 1, 14))
      item1 = create(:dimensions_item, primary_organisation_content_id: 'org-1')
      item2 = create(:dimensions_item, primary_organisation_content_id: 'org-2')

      metric1 = create(:metric, dimensions_item: item1, dimensions_date: day0)
      metric2 = create(:metric, dimensions_item: item1, dimensions_date: day1)
      create(:metric, dimensions_item: item2, dimensions_date: day2)

      series = described_class.new.by_organisation_id('org-1').run

      expect(series).to match_array([metric1, metric2])
    end
  end

  context "by_base_path" do
    it "returns a series of metrics for a base path" do
      day0 = create(:dimensions_date, date: Date.new(2018, 1, 12))
      day1 = create(:dimensions_date, date: Date.new(2018, 1, 13))
      day2 = create(:dimensions_date, date: Date.new(2018, 1, 14))
      item1 = create(:dimensions_item, base_path: '/path1')
      item2 = create(:dimensions_item, base_path: '/path2')

      metric1 = create(:metric, dimensions_item: item1, dimensions_date: day0)
      metric2 = create(:metric, dimensions_item: item1, dimensions_date: day1)
      metric3 = create(:metric, dimensions_item: item1, dimensions_date: day2)
      create(:metric, dimensions_item: item2, dimensions_date: day1)
      create(:metric, dimensions_item: item2, dimensions_date: day2)

      results = described_class.new.by_base_path('/path1').run

      expect(results).to match_array([metric1, metric2, metric3])
    end
  end
end
