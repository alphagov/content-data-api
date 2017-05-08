require 'rails_helper'
require 'features/pagination_spec_helper'

RSpec.feature "Content Items List", type: :feature do
  background do
    @content_items = create_list :content_item, 3
  end

  context "list the content items" do
    scenario "the user sees a list of all unfiltered content items" do
      visit 'content_items'

      expect(page).to have_css('table tbody tr', count: 3)
    end

    describe "user can navigate paged lists of content items" do
      it_behaves_like 'a paginated list', 'content_items'
    end
  end

  scenario "Renders the table header" do
    visit "/content_items"

    expect(page).to have_selector('thead', text: 'Title')
    expect(page).to have_selector('thead tr:first-child th', text: 'Doc type')
    expect(page).to have_selector('thead tr:first-child th', text: 'Page views (1mth)')
    expect(page).to have_selector('thead tr:first-child th', text: 'Last Updated')
  end
end
