RSpec.describe Etl::Aggregations::Monthly do
  subject { described_class }

  let(:date) { Date.new(2018, 2, 20) }

  let(:edition1) { create :edition, base_path: "/path1", live: true, date: "2018-02-20" }
  let(:edition2) { create :edition, base_path: "/path2", live: true, date: "2018-02-20" }

  it "calculates monthly aggregations for a given date" do
    create :metric, edition: edition1, date: "2018-02-20", pviews: 20, upviews: 10, useful_yes: 50, useful_no: 50
    create :metric, edition: edition1, date: "2018-02-21", pviews: 40, upviews: 20, useful_yes: 50, useful_no: 50
    create :metric, edition: edition1, date: "2018-02-22", pviews: 60, upviews: 30, useful_yes: 50, useful_no: 50

    create :metric, edition: edition2, date: "2018-02-20", pviews: 100, upviews: 10, useful_yes: 50, useful_no: 50
    create :metric, edition: edition2, date: "2018-02-21", pviews: 200, upviews: 20, useful_yes: 50, useful_no: 50

    subject.process(date: date)

    results = Aggregations::MonthlyMetric.all.order(pviews: :asc)

    expect(results.count).to eq(2)
    expect(results).to all(have_attributes(dimensions_month_id: "2018-02"))

    expect(results.first).to have_attributes(
      dimensions_edition_id: edition1.id,
      pviews: 120,
      upviews: 60,
      satisfaction: 0.5,
    )
    expect(results.second).to have_attributes(
      dimensions_edition_id: edition2.id,
      pviews: 300,
      upviews: 30,
      satisfaction: 0.5,
    )
  end

  it "can be applied multiple times for different months" do
    create :metric, edition: edition1, date: "2018-01-31", pviews: 20, upviews: 10
    create :metric, edition: edition1, date: "2018-02-21", pviews: 40, upviews: 20
    create :metric, edition: edition1, date: "2018-03-01", pviews: 60, upviews: 30

    subject.process(date: Date.new(2018, 1, 1))
    subject.process(date: Date.new(2018, 2, 1))
    subject.process(date: Date.new(2018, 3, 1))

    results = Aggregations::MonthlyMetric.all

    expect(results.count).to eq(3)
  end

  it "does not include metrics from other months in the calculations" do
    create :metric, edition: edition1, date: "2018-01-31", pviews: 20, upviews: 10
    create :metric, edition: edition1, date: "2018-02-21", pviews: 40, upviews: 20
    create :metric, edition: edition1, date: "2018-03-01", pviews: 60, upviews: 30

    subject.process(date: date)

    results = Aggregations::MonthlyMetric.all

    expect(results.count).to eq(1)
    expect(results.first).to have_attributes(
      dimensions_month_id: "2018-02",
      dimensions_edition_id: edition1.id,
      pviews: 40,
      upviews: 20,
    )
  end

  Metric.daily_metrics.reject { |metric| metric.name == "satisfaction" }.map(&:name).each do |metric_name|
    it "Calculates aggregations for metric: `#{metric_name}`" do
      create :metric, edition: edition1, date: "2018-02-21", metric_name => 10
      create :metric, edition: edition1, date: "2018-02-22", metric_name => 20

      subject.process(date: date)

      expect(Aggregations::MonthlyMetric.first).to have_attributes(metric_name => 30)
    end
  end

  describe "it can run multiple times for any month" do
    it "is idempotent" do
      create :metric, edition: edition1, date: "2018-02-21", pviews: 40, upviews: 20

      subject.process(date: date)
      subject.process(date: date)

      results = Aggregations::MonthlyMetric.all

      expect(results.count).to eq(1)
    end

    it "does not delete aggregations for other months" do
      last_month = (date - 30.days)

      create :metric, edition: edition1, date: "2018-02-21", pviews: 40, upviews: 20
      subject.process(date: date)

      create :metric, edition: edition1, date: "2018-01-21", pviews: 40, upviews: 20
      subject.process(date: last_month)

      subject.process(date: date)
      subject.process(date: last_month)

      expect(Aggregations::MonthlyMetric.where(dimensions_month_id: "2018-01").count).to eq(1)
      expect(Aggregations::MonthlyMetric.where(dimensions_month_id: "2018-02").count).to eq(1)
    end
  end
end
