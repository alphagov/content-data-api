RSpec.describe Reports::Series do
  include MetricsHelpers
  context "all" do
    it "returns a series of all metrics" do
      today = Date.today
      create_metric(base_path: '/path/1', date: today)

      expect(described_class.new.run.one?).to eq(true)
    end
  end

  context "between" do
    it "returns metrics for a given date range" do
      metric1 = create_metric(base_path: '/the/path', date: '2018-5-13')
      metric2 = create_metric(base_path: '/the/path', date: '2018-5-14')
      create_metric(base_path: '/the/path', date: '2018-5-24')
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

      metric1 = create_metric base_path: '/path/1', date: today, edition: { word_count: 10_000 }
      metric2 = create_metric base_path: '/path/2', date: tomorrow, edition: { word_count: 20_000 }
      metric3 = create_metric base_path: '/path/3', date: tomorrow

      series = described_class.new.run

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
      create(:facts_edition, dimensions_item: item1, dimensions_date: day0)


      metric1 = create(:metric, dimensions_item: item1, dimensions_date: day0)
      metric2 = create(:metric, dimensions_item: item1, dimensions_date: day1)
      create(:metric, dimensions_item: item2, dimensions_date: day2)

      series = described_class.new.by_organisation_id('org-1').run

      expect(series).to match_array([metric1, metric2])
    end

    it 'ignores parameters when blank' do
      item = create(:dimensions_item)
      metric = create(:metric, dimensions_item: item)
      today = Dimensions::Date.for(Date.today)
      create(:facts_edition, dimensions_item: item,
        dimensions_date: today)

      expect(described_class.new.by_organisation_id('').run).to match_array([metric])
    end
  end

  context "by_base_path" do
    it "returns a series of metrics for a base path" do
      day0 = create(:dimensions_date, date: Date.new(2018, 1, 12))
      day1 = create(:dimensions_date, date: Date.new(2018, 1, 13))
      day2 = create(:dimensions_date, date: Date.new(2018, 1, 14))
      item1 = create(:dimensions_item, base_path: '/path1')
      item2 = create(:dimensions_item, base_path: '/path2')
      create(:facts_edition, dimensions_item: item1, dimensions_date: day0)

      metric1 = create(:metric, dimensions_item: item1, dimensions_date: day0)
      metric2 = create(:metric, dimensions_item: item1, dimensions_date: day1)
      metric3 = create(:metric, dimensions_item: item1, dimensions_date: day2)
      create(:metric, dimensions_item: item2, dimensions_date: day1)
      create(:metric, dimensions_item: item2, dimensions_date: day2)

      results = described_class.new.by_base_path('/path1').run

      expect(results).to match_array([metric1, metric2, metric3])
    end

    it 'ignores parameters when blank' do
      item = create(:dimensions_item)
      metric = create(:metric, dimensions_item: item)
      today = Dimensions::Date.for(Date.today)
      create(:facts_edition, dimensions_item: item,
        dimensions_date: today)

      expect(described_class.new.by_base_path('').run).to match_array([metric])
    end
  end

  describe '#content_items' do
    it 'return the content items included in the report' do
      day0 = create(:dimensions_date, date: Date.new(2018, 1, 12))
      day1 = create(:dimensions_date, date: Date.new(2018, 1, 13))
      day2 = create(:dimensions_date, date: Date.new(2018, 1, 14))
      item1 = create(:dimensions_item, base_path: '/path1')
      item2 = create(:dimensions_item, base_path: '/path2')
      create(:facts_edition, dimensions_item: item1, dimensions_date: day0)

      create(:metric, dimensions_item: item1, dimensions_date: day0)
      create(:metric, dimensions_item: item1, dimensions_date: day1)
      create(:metric, dimensions_item: item1, dimensions_date: day2)
      create(:metric, dimensions_item: item2, dimensions_date: day1)
      create(:metric, dimensions_item: item2, dimensions_date: day2)

      expect(described_class.new.content_items).to match_array([item1, item2])
    end
  end
end
