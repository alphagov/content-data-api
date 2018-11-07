RSpec.describe Aggregations::SearchLastSixMonths, type: :model do
  subject { described_class }

  it 'aggregates metrics for the last six months' do
    edition1 = create :edition, base_path: '/path1', date: 2.months.ago
    create :metric, edition: edition1, date: Date.yesterday, upviews: 5, useful_yes: 6, useful_no: 7, searches: 8
    create :metric, edition: edition1, date: 3.months.ago, upviews: 10, useful_yes: 7, useful_no: 8, searches: 9
    create :metric, edition: edition1, date: 7.months.ago, upviews: 15, useful_yes: 8, useful_no: 9, searches: 10

    subject.refresh

    expect(subject.count).to eq(1)
    expect(subject.first).to have_attributes(upviews: 15, useful_yes: 13, useful_no: 15, searches: 17)
  end

  it 'aggregates by warehouse_item_id' do
    edition1 = create :edition, warehouse_item_id: 'warehouse_item_id1', date: 5.months.ago
    edition2 = create :edition, warehouse_item_id: 'warehouse_item_id2', date: 2.months.ago

    create :metric, edition: edition1, date: 3.months.ago
    create :metric, edition: edition1, date: 4.months.ago
    create :metric, edition: edition2, date: 5.months.ago

    subject.refresh

    expect(subject.pluck(:dimensions_edition_id)).to match_array([edition1.id, edition2.id])
  end

  describe 'Boundaries' do
    it 'does not include metrics before 3 months' do
      edition1 = create :edition, warehouse_item_id: 'warehouse_item_id1', date: 1.months.ago
      create :metric, edition: edition1, date: (6.months.ago - 1.day)

      subject.refresh

      expect(subject.count).to eq(0)
    end

    it 'does include yesterday' do
      edition1 = create :edition, warehouse_item_id: 'warehouse_item_id1', date: 1.months.ago
      create :metric, edition: edition1, date: Date.yesterday

      subject.refresh

      expect(subject.count).to eq(1)
    end
  end


  it 'is linked to the latest dimension edition' do
    edition1 = create :edition
    edition2 = create :edition, replaces: edition1

    create :metric, edition: edition1, date: 3.months.ago
    create :metric, edition: edition2, date: 4.month.ago

    subject.refresh

    expect(subject.count).to eq(1)
    expect(subject.first).to have_attributes(dimensions_edition_id: edition2.id)
  end
end
