RSpec.describe Etl::Aggregations::Monthly do
  subject { described_class }

  let(:date) { Date.new(2018, 2, 20) }

  let(:edition1) { create :edition, base_path: '/path1', latest: true, date: '2018-02-20' }
  let(:edition2) { create :edition, base_path: '/path2', latest: true, date: '2018-02-20' }

  before do

  end

  it 'calculates the monthly aggregations for a month' do
    create :metric, edition: edition1, date: '2018-02-20', pviews: 20, upviews: 10
    create :metric, edition: edition1, date: '2018-02-21', pviews: 40, upviews: 20
    create :metric, edition: edition1, date: '2018-02-22', pviews: 60, upviews: 30

    create :metric, edition: edition2, date: '2018-02-20', pviews: 100, upviews: 10
    create :metric, edition: edition2, date: '2018-02-21', pviews: 200, upviews: 20

    subject.process(date: date)

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

  it 'does not include metrics from other months' do
    create :metric, edition: edition1, date: '2018-01-31', pviews: 20, upviews: 10
    create :metric, edition: edition1, date: '2018-02-21', pviews: 40, upviews: 20
    create :metric, edition: edition1, date: '2018-03-01', pviews: 60, upviews: 30

    subject.process(date: date)

    results = Aggregations::MonthlyMetric.all

    expect(results.count).to eq(1)
    expect(results.first).to have_attributes(
      dimensions_month_id: '2018-02',
      dimensions_edition_id: edition1.id,
      pviews: 40,
      upviews: 20,
    )
  end
end
