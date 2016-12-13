require 'rails_helper'

RSpec.feature "Content Item's Pagination", type: :feature do
  let(:organisation) { create(:organisation_with_content_items, content_items_count: 3) }

  before do
    Kaminari.configure do |config|
      @default_per_page = config.default_per_page
      config.default_per_page = 2
    end
  end

  after do
    Kaminari.configure do |config|
      config.default_per_page = @default_per_page
    end
  end

  context "When user navigates to" do
    scenario "the first page, the current page number is 1" do
      visit "organisations/#{organisation.id}/content_items"

      expect(page).to have_selector('nav.pagination .current', text: 1)
    end

    scenario "the previous page from page 2, the current page number is 1" do
      visit "organisations/#{organisation.id}/content_items?page=2"
      click_on "Prev"

      expect(page).to have_selector('nav.pagination .current', text: 1)
    end

    scenario "the last page, the current page number is 2" do
      visit "organisations/#{organisation.id}/content_items"
      within("nav.pagination") do
        click_on "Last"
      end

      expect(page).to have_selector('nav.pagination .current', text: 2)
    end

    scenario "the next page, the current page number is 2" do
      visit "organisations/#{organisation.id}/content_items"
      click_on "Next"

      expect(page).to have_selector('nav.pagination .current', text: 2)
    end
  end

  xscenario "sees the total number of pages"
end
