require 'features/pagination_spec_helper'

RSpec.feature "Filter in content items", type: :feature do
  before do
    FactoryGirl.create(:user)
  end

  context "filtering by search term" do
    scenario "the user enters a text in the search box and retrieves a filtered list" do
      create :content_item, title: "some text"
      create :content_item, title: "another text"

      visit "/content_items"
      fill_in 'query', with: 'some text'
      click_on "Filter"

      expect(page).to have_selector('main tbody tr', count: 1)
    end

    scenario "the user enters a text in the search box and retrieves a filtered list" do
      create :content_item, title: "title - a"
      create :content_item, title: "title - b"

      visit "/content_items?order=desc&sort=title"
      fill_in 'query', with: 'title -'
      click_on "Filter"

      expect(page).to have_selector('main tbody tr:first', text: 'title - b')
    end

    scenario "show the query entered by the user after filtering" do
      visit "/content_items"
      fill_in 'query', with: 'a search value'
      click_on "Filter"

      expect(page).to have_field(:query, with: 'a search value')
    end
  end

  context "filtering by organisation" do
    scenario "the user selects an organisation from the organisations select box, clicks the filter button and retrieves a filtered list of the organisation's content items" do
      create :organisation, content_id: "the-content-id-1", title: "org 1"

      visit "/content_items"
      select "org 1", from: "organisation_content_id"
      click_on "Filter"

      expected_path = "organisation_content_id=the-content-id-1"

      expect(current_url).to include(expected_path)
    end

    scenario "the users previously filtered organisation is selected after filtering" do
      create :organisation, title: "org 1"

      visit "/content_items"
      select "org 1", from: "organisation_content_id"
      click_on "Filter"

      expect(page).to have_select(:organisation_content_id, selected: 'org 1')
    end
  end

  context "filtering by taxon" do
    scenario "the user selects a taxon from the taxons box, clicks the filter button and retrieves the filtered list of taxon's content items" do
      create :taxonomy, title: "taxon 1", content_id: "123"

      visit "/content_items"
      select "taxon 1", from: "taxonomy_content_id"
      click_on "Filter"

      expected_path = "taxonomy_content_id=123"

      expect(current_url).to include(expected_path)
    end

    scenario "the users previously filtered taxonomy is selected after filtering" do
      create :taxonomy, title: "taxon 1"

      visit "/content_items"
      select "taxon 1", from: "taxonomy_content_id"
      click_on "Filter"

      expect(page).to have_select(:taxonomy_content_id, selected: 'taxon 1')
    end

    scenario "the user's previously filtered taxonomy is selected after sorting" do
      create :taxonomy, title: "taxon 1", content_id: "123"

      visit "content_items"
      page.select "taxon 1", from: "taxonomy_content_id"
      click_on "Filter"

      click_on "Title"
      expect(page).to have_select(:taxonomy_content_id, selected: "taxon 1")
    end
  end

  context "additional filters" do
    scenario "the user cannot see the additional filters by default", js: true do
      visit "/content_items"

      expect(page).to have_selector('#additionalFilters', visible: false)
    end

    scenario "the user can toggle the visibility of the additional filters", js: true do
      visit "/content_items"

      click_on "More filter options"

      expect(page).to have_selector('#additionalFilters', visible: true)
    end
  end
end
