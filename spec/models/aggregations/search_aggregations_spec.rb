RSpec.describe Aggregations::SearchLastMonth, type: :model do
  include AggregationsSupport

  subject { described_class }

  it_behaves_like "a materialized view", described_class.table_name
  include_examples "calculates satisfaction", Time.zone.today.last_month.end_of_month
  include_examples "includes edition attributes", Time.zone.today.last_month.end_of_month

  let(:from) { Time.zone.today.last_month.beginning_of_month }
  let(:to) { Time.zone.today.last_month.end_of_month }

  it "aggregates metrics for the last month" do
    edition1 = create :edition, base_path: "/path1", date: "2018-01-10"
    create :metric, edition: edition1, date: from, upviews: 5, useful_yes: 1, useful_no: 1, searches: 8
    create :metric, edition: edition1, date: to, upviews: 10, useful_yes: 73, useful_no: 23, searches: 9
    create :metric, edition: edition1, date: (from + 15.days), upviews: 15, useful_yes: 1, useful_no: 1, searches: 10

    recalculate_aggregations!

    expect(subject.count).to eq(1)
    expect(subject.first).to have_attributes(
      upviews: 30,
      useful_yes: 75,
      useful_no: 25,
      searches: 27,
      satisfaction: 0.75,
    )
  end

  it "aggregates by warehouse_item_id" do
    edition1 = create :edition, warehouse_item_id: "warehouse_item_id1", date: 6.months.ago
    edition2 = create :edition, warehouse_item_id: "warehouse_item_id2", date: 8.months.ago

    create :metric, edition: edition1, date: from
    create :metric, edition: edition1, date: from + 1.day
    create :metric, edition: edition2, date: from + 2.days

    recalculate_aggregations!

    expect(subject.pluck(:dimensions_edition_id)).to match_array([edition1.id, edition2.id])
  end

  describe "Boundaries" do
    it "does not include metrics before last month" do
      edition1 = create :edition, warehouse_item_id: "warehouse_item_id1", date: 1.month.ago
      create :metric, edition: edition1, date: (from - 1.day)

      recalculate_aggregations!

      expect(subject.count).to eq(0)
    end

    it "does not include metrics after last month" do
      edition1 = create :edition, warehouse_item_id: "warehouse_item_id1", date: 1.month.ago
      create :metric, edition: edition1, date: (to + 1.day)

      recalculate_aggregations!

      expect(subject.count).to eq(0)
    end
  end

  it "is linked to the live dimension edition" do
    edition1 = create :edition
    edition2 = create :edition, replaces: edition1

    create :metric, edition: edition1, date: from
    create :metric, edition: edition2, date: from + 1.day

    recalculate_aggregations!

    expect(subject.count).to eq(1)
    expect(subject.first).to have_attributes(dimensions_edition_id: edition2.id)
  end
end
