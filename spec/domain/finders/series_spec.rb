RSpec.describe Finders::Series do
  let!(:day1) { Date.new(2018, 1, 13) }
  let!(:day2) { Date.new(2018, 1, 14) }
  let!(:day3) { Date.new(2018, 1, 15) }
  let!(:content_id) { SecureRandom.uuid }
  let!(:base_path) { "/base_path" }
  let!(:edition) { create :edition, date: day1, content_id:, base_path:, locale: "en" }

  before do
    create :metric, edition:, date: day3, pviews: 30
    create :metric, edition:, date: day1, pviews: 10
    create :metric, edition:, date: day2, pviews: 20
  end

  it "return the time series in order" do
    series = Finders::Series.new("pviews", Facts::Metric.all)
    expect(series.time_series).to eq([
      { date: "2018-01-13", value: 10 },
      { date: "2018-01-14", value: 20 },
      { date: "2018-01-15", value: 30 },
    ])
  end

  it "return the total value for time period" do
    series = Finders::Series.new("pviews", Facts::Metric.all)
    expect(series.total).to eq 60
  end
end
