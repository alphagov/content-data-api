RSpec.feature 'Live pages report', type: :feature do
  scenario 'Navigate to a live pages report from the home page' do
    given_i_am_logged_in
    when_i_view_the_home_page
    then_i_can_navigate_to_a_live_pages_report
  end

  scenario 'Live pages report shows the total live pages each day' do
    given_i_am_logged_in
    and_there_is_historical_page_data
    when_i_navigate_to_the_live_pages_report
    then_i_can_see_the_total_live_pages_each_day
  end

  scenario 'Filtering by organisation' do
    given_i_am_logged_in
    and_there_is_historical_page_data
    when_i_navigate_to_the_live_pages_report
    then_i_can_filter_the_report_by_organisation
  end

  around(:example) do |example|
    Timecop.freeze(Time.local(2018, 1, 1)) do
      example.run
    end
  end

  def given_i_am_logged_in
    create(:user)
  end

  def and_there_is_historical_page_data
    # Create dimensions for the last 7 days
    dates = (7.days.ago.to_date..Date.yesterday)
              .map { |date| create(:dimensions_date, date: date) }

    # We have two publishing organisations
    ministry_of_love = create(:dimensions_organisation, title: 'Ministry of Love')
    ministry_of_peace = create(:dimensions_organisation, title: 'Ministry of Peace')

    # On Monday they publish once, twice on Tuesday, three times on Wednesday etc
    dates.map do |date|
      items = create_list(:dimensions_item, date.day_of_week)

      metrics = items.map do |item|
        [
          Facts::Metric.new(dimensions_date: date,
                            dimensions_item: item,
                            dimensions_organisation: ministry_of_love),

          Facts::Metric.new(dimensions_date: date,
                            dimensions_item: item,
                            dimensions_organisation: ministry_of_peace)
        ]
      end

      Facts::Metric.import(metrics.flatten)
    end
  end

  def when_i_view_the_home_page
    @home_page = ContentPerformanceManager.home_page
    @home_page.load
  end

  def when_i_navigate_to_the_live_pages_report
    @live_pages_report = ContentPerformanceManager.live_pages_report
    @live_pages_report.load
  end

  def then_i_can_navigate_to_a_live_pages_report
    expect(@home_page.navigation.reports['href'])
      .to eq('/content/reports/live-pages')
  end

  def then_i_can_see_the_total_live_pages_each_day
    expect(@live_pages_report).to have_line_chart
    expect(@live_pages_report).to have_summary_table

    @live_pages_report.summary_table do |summary_table|
      expect(summary_table.dates.collect(&:text))
        .to contain_exactly('31 December 2017',
                            '30 December 2017',
                            '29 December 2017',
                            '28 December 2017',
                            '27 December 2017',
                            '26 December 2017',
                            '25 December 2017')

      expect(summary_table.live_pages.collect(&:text))
        .to contain_exactly('14', '12', '10', '8', '6', '4', '2')
    end
  end

  def then_i_can_filter_the_report_by_organisation
    @live_pages_report.filter do |filter|
      filter.organisation.select 'Ministry of Peace'
      filter.submit.click
    end

    @live_pages_report.summary_table do |summary_table|
      expect(summary_table.dates.collect(&:text))
        .to contain_exactly('31 December 2017',
                            '30 December 2017',
                            '29 December 2017',
                            '28 December 2017',
                            '27 December 2017',
                            '26 December 2017',
                            '25 December 2017')

      expect(summary_table.live_pages.collect(&:text))
        .to contain_exactly('7', '6', '5', '4', '3', '2', '1')
    end
  end
end
