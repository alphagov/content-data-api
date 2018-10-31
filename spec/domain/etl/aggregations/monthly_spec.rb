RSpec.describe Etl::Aggregations::Monthly do
  subject { described_class }
  let!(:edition1) { create :edition, base_path: '/path1', latest: true, date: '2018-02-20' }
  let!(:edition2) { create :edition, base_path: '/path2', latest: true, date: '2018-02-20' }

  it 'calculates the monthly aggregations for a month' do
    create :metric, edition: edition1, date: '2018-02-20', pviews: 20, upviews: 10
    create :metric, edition: edition1, date: '2018-02-21', pviews: 40, upviews: 20
    create :metric, edition: edition1, date: '2018-02-22', pviews: 60, upviews: 30

    create :metric, edition: edition2, date: '2018-02-20', pviews: 100, upviews: 10
    create :metric, edition: edition2, date: '2018-02-21', pviews: 200, upviews: 20

    subject.process(date: Date.new(2018, 2, 20))

    results = Aggregations::MonthlyMetric.all

    expect(results.count).to eq(2)
    expect(results).to all(have_attributes(dimensions_month_id: '2018-02'))

    expect(results.first).to have_attributes(
      dimensions_edition_id: edition1.id,
      pviews: 120,
      upviews: 60
    )
    expect(results.second).to have_attributes(
      dimensions_edition_id: edition2.id,
      pviews: 300,
      upviews: 30
    )
  end
end
