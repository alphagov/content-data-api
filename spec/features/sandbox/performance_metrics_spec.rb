RSpec.feature 'Performance metrics', type: :feature do
  include MetricsHelpers
  before do
    create(:user)
  end

  around do |example|
    Timecop.freeze(Date.new(2018, 1, 15)) { example.run }
  end

  scenario 'Show total of content items' do
    create_metric base_path: '/path/1', date: '2018-01-12'
    create_metric base_path: '/path/1', date: '2018-01-13'
    create_metric base_path: '/path/2', date: '2018-01-13'

    visit '/sandbox'

    fill_in 'From:', with: '2018-01-13'
    fill_in 'To:', with: '2018-01-15'
    click_button 'Filter'

    expect(page).to have_selector('.total-items .total', text: 'Total = 2')
  end

  context 'Performance metrics' do
    metrics = %w(
       pageviews
       unique_pageviews
       feedex_comments
       is_this_useful_yes
       is_this_useful_no
       number_of_internal_searches
       entrances
       exits
       bounce_rate
       avg_time_on_page
      )

    metrics.each do |metric_name|
      scenario "Show Stats for #{metric_name}" do
        create_metric base_path: '/path/1', date: '2018-01-12', daily: { metric_name => 10 }
        create_metric base_path: '/path/2', date: '2018-01-13', daily: { metric_name => 10 }

        visit '/sandbox'

        fill_in 'From:', with: '2018-01-1'
        fill_in 'To:', with: '2018-01-30'
        select metric_name, from: 'metric1'
        click_button 'Filter'

        expect(page).to have_selector(".#{metric_name} .total", text: 'Total = 20')
        expect(page).to have_selector(".#{metric_name} .average", text: 'Avg = 10.00')
      end
    end
  end
end
