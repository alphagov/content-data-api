RSpec.feature "Show metrics", type: :feature do
  before do
    create(:user)
  end

  scenario 'Show totals for GA metrics' do
    day1 = Dimensions::Date.build(Date.new(2018, 1, 13))
    day2 = Dimensions::Date.build(Date.new(2018, 1, 14))
    item1 = create(:dimensions_item, content_id: 'id1')
    item2 = create(:dimensions_item, content_id: 'id2')

    Facts::Metric.create!(dimensions_item: item1, dimensions_date: day1, pageviews: 10, unique_pageviews: 10)
    Facts::Metric.create!(dimensions_item: item1, dimensions_date: day2, pageviews: 20, unique_pageviews: 20)
    Facts::Metric.create!(dimensions_item: item2, dimensions_date: day1, pageviews: 20, unique_pageviews: 20)
    Facts::Metric.create!(dimensions_item: item2, dimensions_date: day2, pageviews: 30, unique_pageviews: 30)

    visit '/sandbox'

    expect(page).to have_text('80 pageviews (total)')
    expect(page).to have_text('20.0 unique pageviews (avg)')
  end
end
