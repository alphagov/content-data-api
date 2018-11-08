RSpec.describe Aggregations::SearchLastMonth, type: :model do
  subject { described_class }

  it_behaves_like 'a materialized view', described_class.table_name

  let(:from) { Date.today.last_month.beginning_of_month }
  let(:to) { Date.today.last_month.end_of_month }

  it 'aggregates metrics for the last month' do
    edition1 = create :edition, base_path: '/path1', date: '2018-01-10'
    create :metric, edition: edition1, date: from, upviews: 5, useful_yes: 6, useful_no: 7, searches: 8
    create :metric, edition: edition1, date: to, upviews: 10, useful_yes: 7, useful_no: 8, searches: 9
    create :metric, edition: edition1, date: (from + 15.days), upviews: 15, useful_yes: 8, useful_no: 9, searches: 10

    Etl::Aggregations::Monthly.process(date: from)
    subject.refresh

    expect(subject.count).to eq(1)
    expect(subject.first).to have_attributes(
      upviews: 30,
      useful_yes: 21,
      useful_no: 24,
      searches: 27,
    )
  end

  it 'aggregates by warehouse_item_id' do
    edition1 = create :edition, warehouse_item_id: 'warehouse_item_id1', date: 6.months.ago
    edition2 = create :edition, warehouse_item_id: 'warehouse_item_id2', date: 8.months.ago

    create :metric, edition: edition1, date: from
    create :metric, edition: edition1, date: from + 1.day
    create :metric, edition: edition2, date: from + 2.days

    Etl::Aggregations::Monthly.process(date: from)
    subject.refresh

    expect(subject.pluck(:dimensions_edition_id)).to match_array([edition1.id, edition2.id])
  end


  describe 'Boundaries' do
    it 'does not include metrics before last month' do
      edition1 = create :edition, warehouse_item_id: 'warehouse_item_id1', date: 1.months.ago
      create :metric, edition: edition1, date: (from - 1.day)

      Etl::Aggregations::Monthly.process(date: from)
      subject.refresh

      expect(subject.count).to eq(0)
    end

    it 'does not include metrics after last month' do
      edition1 = create :edition, warehouse_item_id: 'warehouse_item_id1', date: 1.months.ago
      create :metric, edition: edition1, date: (to + 1.day)

      Etl::Aggregations::Monthly.process(date: from)
      subject.refresh

      expect(subject.count).to eq(0)
    end
  end

  it 'is linked to the latest dimension edition' do
    edition1 = create :edition
    edition2 = create :edition, replaces: edition1

    create :metric, edition: edition1, date: from
    create :metric, edition: edition2, date: from + 1.day

    Etl::Aggregations::Monthly.process(date: from)
    subject.refresh

    expect(subject.count).to eq(1)
    expect(subject.first).to have_attributes(dimensions_edition_id: edition2.id)
  end
end
