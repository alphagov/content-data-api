require 'rails_helper'

RSpec.feature "Summary area", type: :feature do
  background do
    @content_items = create_list :content_item, 3
  end

  scenario "user can see the total number of pages" do
    visit 'content_items'

    expect(page).to have_selector('.summary-item-value', text: 3)
  end
end
