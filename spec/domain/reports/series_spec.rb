RSpec.describe Reports::Series do
  let!(:day1) { Date.new(2018, 1, 13) }
  let!(:day2) { Date.new(2018, 1, 14) }
  let!(:day3) { Date.new(2018, 1, 15) }
  let!(:content_id) { SecureRandom.uuid }
  let!(:base_path) { '/base_path' }
  let!(:item) { create :edition, date: day1, content_id: content_id, base_path: base_path, locale: 'en' }

  before do
    create :metric, edition: item, date: day1, pviews: 10
    create :metric, edition: item, date: day2, pviews: 20
    create :metric, edition: item, date: day3, pviews: 30
  end

  it 'presents the values_by_date' do
    series = Reports::Series.new('pviews', Facts::Metric.all)
    expect(series.values_by_date).to eq expected_values
  end

  it 'presents the total' do
    series = Reports::Series.new('pviews', Facts::Metric.all)
    expect(series.total).to eq 60
  end

  it 'presents the latest' do
    series = Reports::Series.new('pviews', Facts::Metric.all)
    expect(series.latest).to eq 30
  end

  def expected_values
    [
      { "2018-01-13" => 10 },
      { "2018-01-14" => 20 },
      { "2018-01-15" => 30 }
    ]
  end
end
