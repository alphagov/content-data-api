RSpec.describe Aggregations::SearchLastThirtyDays, type: :model do
  include AggregationsSupport

  subject { described_class }

  let(:two_days_ago) { Time.zone.today - 2 }

  it_behaves_like "a materialized view", described_class.table_name
  include_examples "calculates satisfaction", Time.zone.today - 2
  include_examples "includes edition attributes", Time.zone.today - 2

  it "aggregates metrics for the last 30 days" do
    edition1 = create :edition, base_path: "/path1", date: 2.months.ago
    create :metric, edition: edition1, date: two_days_ago, upviews: 5, useful_yes: 1, useful_no: 1, searches: 8
    create :metric, edition: edition1, date: 15.days.ago, upviews: 10, useful_yes: 74, useful_no: 24, searches: 9
    create :metric, edition: edition1, date: 31.days.ago, upviews: 15, useful_yes: 8, useful_no: 9, searches: 10

    recalculate_aggregations!

    expect(subject.count).to eq(1)
    expect(subject.first).to have_attributes(upviews: 15, useful_yes: 75, useful_no: 25, searches: 17, satisfaction: 0.75)
  end

  it "aggregates by warehouse_item_id" do
    edition1 = create :edition, warehouse_item_id: "warehouse_item_id1", date: 1.month.ago
    edition2 = create :edition, warehouse_item_id: "warehouse_item_id2", date: 2.months.ago

    create :metric, edition: edition1, date: 15.days.ago
    create :metric, edition: edition1, date: 16.days.ago
    create :metric, edition: edition2, date: 30.days.ago

    recalculate_aggregations!

    expect(subject.pluck(:dimensions_edition_id)).to match_array([edition1.id, edition2.id])
  end

  it "references the live dimension edition" do
    edition1 = create :edition
    edition2 = create :edition, replaces: edition1

    create :metric, edition: edition1, date: 15.days.ago
    create :metric, edition: edition2, date: 15.days.ago

    recalculate_aggregations!

    expect(subject.count).to eq(1)
    expect(subject.first).to have_attributes(dimensions_edition_id: edition2.id)
  end

  it "does not include metrics older than 30 days ago" do
    edition1 = create :edition, warehouse_item_id: "warehouse_item_id1", date: 1.month.ago
    create :metric, edition: edition1, date: 30.days.ago, upviews: 10
    create :metric, edition: edition1, date: 31.days.ago, upviews: 100

    recalculate_aggregations!

    expect(subject.sum(:upviews)).to eq(10)
  end

  it "does not include metrics newer than day before yesterday" do
    edition1 = create :edition, warehouse_item_id: "warehouse_item_id1", date: 1.month.ago
    create :metric, edition: edition1, date: Time.zone.today, upviews: 100
    create :metric, edition: edition1, date: two_days_ago, upviews: 10

    recalculate_aggregations!

    expect(subject.sum(:upviews)).to eq(10)
  end
end
