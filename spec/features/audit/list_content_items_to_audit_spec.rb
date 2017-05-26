require 'features/common/pagination_spec_helper'

RSpec.feature "List Content Items to Audit", type: :feature do
  let!(:user) { FactoryGirl.create(:user) }

  let!(:content_item_1) { FactoryGirl.create(:content_item, title: "All about flooding.") }
  let!(:content_item_2) { FactoryGirl.create(:content_item, title: "All about gardening.") }

  scenario "List Content Items to Audit" do
    content_item_1.update(six_months_page_views: 1234)

    visit audits_path

    expect(page).to have_content("All about flooding.")
    expect(page).to have_content("All about gardening.")
    expect(page).to have_content("1234")
    expect(page).to have_link("All about gardening.", href: "/content_items/#{content_item_2.id}/audit")
  end

  scenario "Default sorting by popularity" do
    content_item_1.update(six_months_page_views: 0)
    content_item_2.update(six_months_page_views: 1234)

    visit audits_path

    expect(page).to have_selector('main tbody tr:first', text: 'All about gardening.')
    expect(page).to have_selector('main tbody tr:2nd', text: 'All about floading.')
  end

  describe "User can navigate paged lists of content items" do
    before { create_list :content_item, 3 }

    it_behaves_like 'a paginated list', 'content_items'
  end
end
