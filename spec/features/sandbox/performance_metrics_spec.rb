RSpec.feature 'Performance metrics', type: :feature do
  before do
    create(:user)
  end

  around do |example|
    Timecop.freeze(Date.new(2018, 1, 15)) { example.run }
  end

  let(:day0) { create :dimensions_date, date: Date.new(2018, 1, 12) }
  let(:day1) { create :dimensions_date, date: Date.new(2018, 1, 13) }

  scenario 'Show total of content items' do
    item1 = create :dimensions_item
    item2 = create :dimensions_item

    create :metric, dimensions_item: item1, dimensions_date: day0
    create :metric, dimensions_item: item1, dimensions_date: day1
    create :metric, dimensions_item: item2, dimensions_date: day1

    visit '/sandbox'

    fill_in 'From:', with: '2018-01-13'
    fill_in 'To:', with: '2018-01-15'
    click_button 'Filter'

    expect(page).to have_selector('.total-items .total', text: 'Total = 2')
  end

  context 'Performance metrics' do
    let(:item1) { create :dimensions_item, content_id: 'id1', locale: 'en' }
    let(:item2) { create :dimensions_item, content_id: 'id2', locale: 'en' }

    metrics = %w(
       pageviews
       unique_pageviews
       feedex_comments
       is_this_useful_yes
       is_this_useful_no
       number_of_internal_searches
      )

    metrics.each do |metric_name|
      scenario "Show Stats for #{metric_name}" do
        create :metric, dimensions_item: item1, dimensions_date: day0, metric_name => 10
        create :metric, dimensions_item: item1, dimensions_date: day1, metric_name => 10

        visit '/sandbox'

        fill_in 'From:', with: '2018-01-1'
        fill_in 'To:', with: '2018-01-30'
        check metric_name
        click_button 'Filter'

        expect(page).to have_selector(".#{metric_name} .total", text: 'Total = 20')
        expect(page).to have_selector(".#{metric_name} .average", text: 'Avg = 10.00')
      end
    end
  end
end
