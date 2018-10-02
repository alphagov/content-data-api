RSpec.describe Reports::Series do
  let!(:day1) { create :dimensions_date, date: Date.new(2018, 1, 13) }
  let!(:day2) { create :dimensions_date, date: Date.new(2018, 1, 14) }
  let!(:day3) { create :dimensions_date, date: Date.new(2018, 1, 15) }
  let!(:content_id) { SecureRandom.uuid }
  let!(:base_path) { '/base_path' }
  let!(:item) { create :dimensions_item, content_id: content_id, base_path: base_path, locale: 'en' }

  before do
    create :metric, dimensions_item: item, dimensions_date: day1, pageviews: 10
    create :metric, dimensions_item: item, dimensions_date: day2, pageviews: 20
    create :metric, dimensions_item: item, dimensions_date: day3, pageviews: 30
    create :facts_edition, dimensions_item: item, dimensions_date: day1
  end

  it 'return the time series' do
    series = Reports::Series.new('pageviews', Facts::Metric.all)
    expect(series.time_series).to eq expected_values
  end

  it 'return the total value for time period' do
    series = Reports::Series.new('pageviews', Facts::Metric.all)
    expect(series.total).to eq 60
  end

  def expected_values
    [
      { date: "2018-01-13", value: 10 },
      { date: "2018-01-14", value: 20 },
      { date: "2018-01-15", value: 30 }
    ]
  end
end
