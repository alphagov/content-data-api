require 'rails_helper'

RSpec.feature "Content Item's Pagination", type: :feature do
  let(:organisation) { create(:organisation_with_content_items, content_items_count: 3) }

  before do
    Kaminari.configure do |config|
      @default_per_page = config.default_per_page
      config.default_per_page = 1
    end
  end

  after do
    Kaminari.configure do |config|
      config.default_per_page = @default_per_page
    end
  end

  context "When user navigates to" do
    scenario "the first page, there is no previous link" do
      visit "organisations/#{organisation.slug}/content_items"

      expect(page).not_to have_selector('.pagination [rel=prev]')
    end

    scenario "the first page, there is a next link" do
      visit "organisations/#{organisation.slug}/content_items"

      expect(page).to have_selector('.pagination [rel=next]')
    end

    scenario "the first page, the next page number is 2" do
      visit "organisations/#{organisation.slug}/content_items"

      expect(page).to have_selector('.pagination .next', text: '2 of 3')
    end

    scenario "the next page from page 1 the previous page number is 1" do
      visit "organisations/#{organisation.slug}/content_items"
      page.find('.pagination a[rel=next]').click

      expect(page).to have_selector('.pagination .prev', text: '1 of 3')
    end

    scenario "the next page from page 1 the next page number is 3" do
      visit "organisations/#{organisation.slug}/content_items"
      page.find('.pagination a[rel=next]').click

      expect(page).to have_selector('.pagination .next', text: '3 of 3')
    end

    scenario "the previous page from page 3 the next page number is 3" do
      visit "organisations/#{organisation.slug}/content_items?page=3"
      page.find('.pagination a[rel=prev]').click

      expect(page).to have_selector('.pagination .next', text: '3 of 3')
    end

    scenario "the previous page from page 3 the previous page number is 1" do
      visit "organisations/#{organisation.slug}/content_items?page=3"
      page.find('.pagination a[rel=prev]').click

      expect(page).to have_selector('.pagination .prev', text: '1 of 3')
    end

    scenario "the last page, there is no next link" do
      visit "organisations/#{organisation.slug}/content_items?page=3"

      expect(page).not_to have_selector('.pagination [rel=next]')
    end

    scenario "the last page, there is a previous link" do
      visit "organisations/#{organisation.slug}/content_items?page=3"

      expect(page).to have_selector('.pagination [rel=prev]')
    end
  end
end
