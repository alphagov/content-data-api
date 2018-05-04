RSpec.feature 'Show aggregated metrics', type: :feature do
  before do
    create(:user)
  end

  describe 'Charts' do
    scenario 'Show charts' do
      visit '/sandbox'

      fill_in 'From:', with: '2018-01-13'
      fill_in 'To:', with: '2018-01-15'
      check 'pageviews'

      click_button 'Filter'

      expect(page).to have_selector('.trends .pageviews')
    end
  end
end
