require "rails_helper"
RSpec.describe "/api/v1/metrics/:content_id", type: :request do
  it "List a metric for a content item between two dates" do
    day1 = Dimensions::Date.build(Date.new(2018, 1, 13))
    day2 = Dimensions::Date.build(Date.new(2018, 1, 14))
    day3 = Dimensions::Date.build(Date.new(2018, 1, 15))
    day4 = Dimensions::Date.build(Date.new(2018, 1, 16))
    item1 = create(:dimensions_item, content_id: 'id1')

    Facts::Metric.create!(dimensions_item: item1, dimensions_date: day1, pageviews: 20, unique_pageviews: 10)
    Facts::Metric.create!(dimensions_item: item1, dimensions_date: day2, pageviews: 10, unique_pageviews: 5)
    Facts::Metric.create!(dimensions_item: item1, dimensions_date: day3, pageviews: 20, unique_pageviews: 10)
    Facts::Metric.create!(dimensions_item: item1, dimensions_date: day4, pageviews: 20, unique_pageviews: 10)

    query_params = {
      metric: 'pageviews',
      from: Date.new(2018, 1, 13),
      to: Date.new(2018, 1, 15),
    }
    get "/api/v1/metrics/id1.json", params: query_params

    json = JSON.parse(response.body)
    expect(json.deep_symbolize_keys).to eq(pageviews_response)
  end

  def pageviews_response
    {
      metadata: {
        metric: 'pageviews',
        total: 50,
        from: '2018-01-13',
        to: '2018-01-15',
        content_id: 'id1',
      },
      results: [
        {
          content_id: 'id1',
          date: '2018-01-13',
          value: 20,
        },
        {
          content_id: 'id1',
          date: '2018-01-14',
          value: 10,
        },
        {
          content_id: 'id1',
          date: '2018-01-15',
          value: 20,
        }
      ]
    }
  end
end
