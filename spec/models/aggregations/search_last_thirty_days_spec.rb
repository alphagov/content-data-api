RSpec.describe Aggregations::SearchLastThirtyDays, type: :model do
  include AggregationsSupport

  subject { described_class }

  it_behaves_like 'a materialized view', described_class.table_name

  it 'aggregates metrics for the last 30 days' do
    edition1 = create :edition, base_path: '/path1', date: 2.months.ago
    create :metric, edition: edition1, date: Date.yesterday, upviews: 5, useful_yes: 6, useful_no: 7, searches: 8
    create :metric, edition: edition1, date: 15.days.ago, upviews: 10, useful_yes: 7, useful_no: 8, searches: 9
    create :metric, edition: edition1, date: 32.days.ago, upviews: 15, useful_yes: 8, useful_no: 9, searches: 10

    recalculate_aggregations!

    expect(subject.count).to eq(1)
    expect(subject.first).to have_attributes(upviews: 15, useful_yes: 13, useful_no: 15, searches: 17)
  end

  it 'aggregates by warehouse_item_id' do
    edition1 = create :edition, warehouse_item_id: 'warehouse_item_id1', date: 1.months.ago
    edition2 = create :edition, warehouse_item_id: 'warehouse_item_id2', date: 2.months.ago

    create :metric, edition: edition1, date: 15.days.ago
    create :metric, edition: edition1, date: 16.days.ago
    create :metric, edition: edition2, date: 30.days.ago

    recalculate_aggregations!

    expect(subject.pluck(:dimensions_edition_id)).to match_array([edition1.id, edition2.id])
  end

  describe 'Boundary: last thirty days from yesterday' do
    it 'include days 31 days ago' do
      edition1 = create :edition, warehouse_item_id: 'warehouse_item_id1', date: 1.months.ago
      create :metric, edition: edition1, date: 31.days.ago, upviews: 10

      recalculate_aggregations!

      expect(subject.sum(:upviews)).to eq(10)
    end

    it 'does not include 32 days ago' do
      edition1 = create :edition, warehouse_item_id: 'warehouse_item_id1', date: 1.months.ago
      create :metric, edition: edition1, date: 32.days.ago, upviews: 10

      recalculate_aggregations!

      expect(subject.sum(:upviews)).to eq(0.0)
    end

    it 'does not include today' do
      edition1 = create :edition, warehouse_item_id: 'warehouse_item_id1', date: 1.months.ago
      create :metric, edition: edition1, date: Date.today, upviews: 10

      recalculate_aggregations!

      expect(subject.sum(:upviews)).to eq(0)
    end

    it 'does include yesterday' do
      edition1 = create :edition, warehouse_item_id: 'warehouse_item_id1', date: 1.months.ago
      create :metric, edition: edition1, date: Date.yesterday, upviews: 10

      recalculate_aggregations!

      expect(subject.sum(:upviews)).to eq(10.0)
    end
  end


  it 'is linked to the latest dimension edition' do
    edition1 = create :edition
    edition2 = create :edition, replaces: edition1

    create :metric, edition: edition1, date: 15.days.ago
    create :metric, edition: edition2, date: 15.days.ago

    recalculate_aggregations!

    expect(subject.count).to eq(1)
    expect(subject.first).to have_attributes(dimensions_edition_id: edition2.id)
  end
end
