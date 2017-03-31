require 'rails_helper'

RSpec.feature "Summary area", type: :feature do
  scenario "user can see the total number of pages" do
    create_list :content_item, 3

    visit 'content_items'

    expect(page).to have_selector('.summary-item-value', text: 3)
  end

  scenario "user can see the total number of pages with zero views" do
    create :content_item, unique_page_views: 1
    create :content_item, unique_page_views: 0

    visit 'content_items'

    expect(page).to have_selector('.summary-item-value', text: 1)
  end
end
