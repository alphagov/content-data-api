RSpec.feature "Show metrics", type: :feature do
  before do
    create(:user)
  end

  scenario 'Show total page views' do
    day1 = Dimensions::Date.build(Date.new(2018, 1, 13))
    day2 = Dimensions::Date.build(Date.new(2018, 1, 14))
    item1 = create(:dimensions_item, content_id: 'id1')
    item2 = create(:dimensions_item, content_id: 'id2')

    Facts::Metric.create!(dimensions_item: item1, dimensions_date: day1, pageviews: 10)
    Facts::Metric.create!(dimensions_item: item1, dimensions_date: day2, pageviews: 20)
    Facts::Metric.create!(dimensions_item: item2, dimensions_date: day1, pageviews: 20)
    Facts::Metric.create!(dimensions_item: item2, dimensions_date: day2, pageviews: 30)

    visit '/sandbox'

    expect(page).to have_text('80 pageviews (total)')
  end
end
