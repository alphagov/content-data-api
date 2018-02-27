RSpec.feature 'Show metrics', type: :feature do
  before do
    create(:user)
  end

  around do |example|
    Timecop.freeze(Date.new(2018, 1, 15)) { example.run }
  end


  scenario 'Show totals for GA metrics between two dates' do
    day0 = Dimensions::Date.build(Date.new(2018, 1, 12))
    day1 = Dimensions::Date.build(Date.new(2018, 1, 13))
    day2 = Dimensions::Date.build(Date.new(2018, 1, 14))
    item1 = create(:dimensions_item, content_id: 'id1')
    item2 = create(:dimensions_item, content_id: 'id2')

    Facts::Metric.create!(dimensions_item: item1, dimensions_date: day0, pageviews: 10, unique_pageviews: 10)
    Facts::Metric.create!(dimensions_item: item1, dimensions_date: day1, pageviews: 10, unique_pageviews: 10)
    Facts::Metric.create!(dimensions_item: item1, dimensions_date: day2, pageviews: 20, unique_pageviews: 20)
    Facts::Metric.create!(dimensions_item: item2, dimensions_date: day1, pageviews: 20, unique_pageviews: 20)
    Facts::Metric.create!(dimensions_item: item2, dimensions_date: day2, pageviews: 30, unique_pageviews: 30)

    visit '/sandbox'

    fill_in 'From:', with: '2018-01-13'
    fill_in 'To:', with: '2018-01-15'
    click_button 'Filter'

    expect(page).to have_selector('.pageviews', text: '80 pageviews (total)')
    expect(page).to have_selector('.unique_pageviews', text: '20.0 unique pageviews (avg)')
  end

  scenario 'Show aggregated numbers between two dates' do
    day1 = Dimensions::Date.build(Date.new(2018, 1, 13))
    day2 = Dimensions::Date.build(Date.new(2018, 1, 14))
    item1 = create(:dimensions_item, content_id: 'id1', base_path: '/path')
    item2 = create(:dimensions_item, content_id: 'id2', base_path: '/path2')

    Facts::Metric.create!(dimensions_item: item1, dimensions_date: day1, pageviews: 10)
    Facts::Metric.create!(dimensions_item: item1, dimensions_date: day2, pageviews: 20)
    Facts::Metric.create!(dimensions_item: item2, dimensions_date: day2, pageviews: 30)

    visit '/sandbox'

    fill_in 'Base path:', with: '/path'
    click_button 'Filter'

    expect(page).to have_selector('.pageviews', text: '30 pageviews (total)')
  end
end
