RSpec.feature 'Show aggregated metrics', type: :feature do
  before do
    create(:user)
  end

  around do |example|
    Timecop.freeze(Date.new(2018, 1, 15)) { example.run }
  end

  let(:day0) { create :dimensions_date, date: Date.new(2018, 1, 12) }
  let(:day1) { create :dimensions_date, date: Date.new(2018, 1, 13) }
  let(:day2) { create :dimensions_date, date: Date.new(2018, 1, 14) }

  let(:item1) { create :dimensions_item, content_id: 'id1' }
  let(:item2) { create :dimensions_item, content_id: 'id2' }

  let(:metric1) { create :metric, dimensions_item: item1, dimensions_date: day0 }
  let(:metric2) { create :metric, dimensions_item: item1, dimensions_date: day1 }
  let(:metric3) { create :metric, dimensions_item: item1, dimensions_date: day2 }
  let(:metric4) { create :metric, dimensions_item: item2, dimensions_date: day1 }
  let(:metric5) { create :metric, dimensions_item: item2, dimensions_date: day2 }

  scenario 'Show aggregated metrics' do
    metric1.update pageviews: 10, unique_pageviews: 10, number_of_issues: 2
    metric2.update pageviews: 10, unique_pageviews: 10, number_of_issues: 4
    metric3.update pageviews: 20, unique_pageviews: 20, number_of_issues: 6
    metric4.update pageviews: 20, unique_pageviews: 20, number_of_issues: 8
    metric5.update pageviews: 30, unique_pageviews: 30, number_of_issues: 10

    item1.update number_of_pdfs: 2, number_of_word_files: 1
    item2.update number_of_pdfs: 4, number_of_word_files: 2

    visit '/sandbox'

    fill_in 'From:', with: '2018-01-13'
    fill_in 'To:', with: '2018-01-15'
    click_button 'Filter'

    expect(page).to have_selector('.pageviews', text: '80 pageviews (total)')
    expect(page).to have_selector('.unique_pageviews', text: '20.0 unique pageviews (avg)')
    expect(page).to have_selector('.feedex_issues', text: '28 Feedex issues (total)')
    expect(page).to have_selector('.number_of_pdfs', text: '12 pdfs (total)')
    expect(page).to have_selector('.number_of_word_files', text: '6 Word files (total)')
  end

  describe 'Filtering' do
    scenario 'by base_path' do
      item1.update base_path: '/path'
      item2.update base_path: '/path2'

      create :metric, dimensions_item: item1, dimensions_date: day1, pageviews: 10
      create :metric, dimensions_item: item1, dimensions_date: day2, pageviews: 20
      create :metric, dimensions_item: item2, dimensions_date: day2, pageviews: 30

      visit '/sandbox'

      fill_in 'Base path:', with: '/path'
      click_button 'Filter'

      expect(page).to have_selector('.pageviews', text: '30 pageviews (total)')
    end
  end
end
