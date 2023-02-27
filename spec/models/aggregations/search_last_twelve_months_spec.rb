RSpec.describe Aggregations::SearchLastTwelveMonths, type: :model do
  include AggregationsSupport

  subject { described_class }

  it_behaves_like "a materialized view", described_class.table_name
  include_examples "calculates satisfaction", Date.yesterday
  include_examples "includes edition attributes", Date.yesterday

  it "aggregates metrics for the last twelve months" do
    edition1 = create :edition, base_path: "/path1", date: 2.months.ago
    create :metric, edition: edition1, date: Date.yesterday, upviews: 5, useful_yes: 1, useful_no: 1, searches: 8
    create :metric, edition: edition1, date: 6.months.ago, upviews: 10, useful_yes: 74, useful_no: 24, searches: 9
    create :metric, edition: edition1, date: 13.months.ago, upviews: 15, useful_yes: 8, useful_no: 9, searches: 10

    recalculate_aggregations!

    expect(subject.count).to eq(1)
    expect(subject.first).to have_attributes(
      upviews: 15,
      useful_yes: 75,
      useful_no: 25,
      satisfaction: 0.75,
      searches: 17,
    )
  end

  it "aggregates by warehouse_item_id" do
    edition1 = create :edition, warehouse_item_id: "warehouse_item_id1", date: 6.months.ago
    edition2 = create :edition, warehouse_item_id: "warehouse_item_id2", date: 8.months.ago

    create :metric, edition: edition1, date: 3.months.ago
    create :metric, edition: edition1, date: 7.months.ago
    create :metric, edition: edition2, date: 10.months.ago

    recalculate_aggregations!

    expect(subject.pluck(:dimensions_edition_id)).to match_array([edition1.id, edition2.id])
  end

  it "references the live dimension edition" do
    edition1 = create :edition
    edition2 = create :edition, replaces: edition1

    create :metric, edition: edition1, date: 2.months.ago
    create :metric, edition: edition2, date: 1.month.ago

    recalculate_aggregations!

    expect(subject.count).to eq(1)
    expect(subject.first).to have_attributes(dimensions_edition_id: edition2.id)
  end

  it "does not include metrics older than 12 months ago" do
    tweleve_months_ago = Date.yesterday - 12.months
    edition1 = create :edition, warehouse_item_id: "warehouse_item_id1", date: 1.month.ago
    create :metric, edition: edition1, date: tweleve_months_ago + 1.day, upviews: 10
    create :metric, edition: edition1, date: tweleve_months_ago, upviews: 100

    recalculate_aggregations!

    expect(subject.sum(:upviews)).to eq(10)
  end

  it "includes metrics for yesterday" do
    edition1 = create :edition, warehouse_item_id: "warehouse_item_id1", date: 1.month.ago
    create :metric, edition: edition1, date: Date.yesterday, upviews: 10

    recalculate_aggregations!

    expect(subject.sum(:upviews)).to eq(10.0)
  end

  it "does not count metrics twice" do
    edition1 = create :edition, warehouse_item_id: "warehouse_item_id1", date: 1.month.ago
    start_date = Date.yesterday
    end_date = 12.months.ago

    (start_date..end_date).each do |date|
      create :metric, edition: edition1, date:, upviews: 10
    end

    recalculate_aggregations!

    expect(subject.sum(:upviews)).to eq(10.0 * Facts::Metric.count)
  end
end
