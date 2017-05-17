require 'rails_helper'

RSpec.feature "Summary area", type: :feature do
  before do
    FactoryGirl.create(:user)
  end

  scenario "user can see the total number of pages" do
    create_list :content_item, 3

    visit 'content_items'

    expect(page).to have_selector('.summary-item-value', text: 3)
  end

  scenario "user can see the total number of pages with zero views" do
    create :content_item, one_month_page_views: 1
    create :content_item, one_month_page_views: 0

    visit 'content_items'

    expect(page).to have_selector('.summary-item-value', text: 1)
  end

  scenario "user can see the total number of pages not updated in the last 6 months" do
    create :content_item, public_updated_at: 7.months.ago
    create :content_item, public_updated_at: Date.today

    visit 'content_items'

    expect(page).to have_selector('.summary-item-value', text: 1)
  end

  scenario "user can see the total number of pages not updated in the last 6 months" do
    create :content_item, number_of_pdfs: 1
    create :content_item, number_of_pdfs: 0

    visit 'content_items'

    expect(page).to have_selector('.summary-item-value', text: "50.0%")
  end
end
