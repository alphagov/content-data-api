RSpec.feature 'Show aggregated metrics', type: :feature do
  before do
    create(:user)
  end

  around do |example|
    Timecop.freeze(Date.new(2018, 1, 15)) { example.run }
  end

  let(:day1) { create :dimensions_date, date: Date.new(2018, 1, 12) }
  let(:day2) { create :dimensions_date, date: Date.new(2018, 1, 13) }

  describe 'Filtering' do
    let(:item1) { create :dimensions_item, base_path: '/path' }
    let(:item2) { create :dimensions_item, base_path: '/path2' }

    scenario 'by base_path' do
      create :metric, dimensions_item: item1, dimensions_date: day1, pageviews: 10
      create :metric, dimensions_item: item1, dimensions_date: day2, pageviews: 20
      create :metric, dimensions_item: item2, dimensions_date: day2, pageviews: 30

      visit '/sandbox'
      check 'pageviews'

      fill_in 'Base path:', with: '/path'
      click_button 'Filter'

      expect(page).to have_selector('.pageviews .total', text: 'Total = 30')
    end

    scenario 'by organisation' do
      item1.update primary_organisation_content_id: 'org-1'
      item2.update primary_organisation_content_id: 'org-2'
      create :metric, dimensions_item: item1, dimensions_date: day1, pageviews: 10
      create :metric, dimensions_item: item2, dimensions_date: day1, pageviews: 30

      visit '/sandbox'
      check 'pageviews'

      fill_in 'Organisation ID:', with: 'org-1'
      click_button 'Filter'

      expect(page).to have_selector('.pageviews .total', text: 'Total = 10')
    end

    scenario 'by date' do
      create :metric, dimensions_item: item1, dimensions_date: day1, pageviews: 10
      create :metric, dimensions_item: item1, dimensions_date: day2, pageviews: 20

      visit '/sandbox'
      check 'pageviews'

      fill_in 'From:', with: '2018-01-12'
      fill_in 'To:', with: '2018-01-12'
      click_button 'Filter'

      expect(page).to have_selector('.pageviews .total', text: 'Total = 10')
    end
  end
end
