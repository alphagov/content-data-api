RSpec.feature "Filter in content items", type: :feature do
  before do
    create(:user)
  end

  context "filtering by search term" do
    scenario "the user enters a text in the search box and retrieves a filtered list" do
      create :content_item, title: "some text"
      create :content_item, title: "another text"

      visit "/content/items"
      fill_in "query", with: "some text"
      click_on "Filter"

      expect(page).to have_selector("main tbody tr", count: 1)
    end

    scenario "the user enters a text in the search box and retrieves a filtered list" do
      create :content_item, title: "title - a"
      create :content_item, title: "title - b"

      visit "/content/items?order=desc&sort=title"
      fill_in "query", with: "title -"
      click_on "Filter"

      expect(page).to have_selector("main tbody tr:first", text: "title - b")
    end

    scenario "show the query entered by the user after filtering" do
      visit "/content/items"
      fill_in 'query', with: 'a search value'
      click_on "Filter"

      expect(page).to have_field(:query, with: 'a search value')
    end
  end

  context "filtering" do
    let!(:hmrc) { create(:organisation, title: "HMRC") }
    let!(:dfe) { create(:organisation, title: "DFE") }

    let!(:felling) { create(:content_item, title: "Tree felling") }
    let!(:vat) { create(:content_item, title: "VAT") }

    before do
      create(:link, source: vat, target: hmrc, link_type: "organisations")
      create(:link, source: vat, target: hmrc, link_type: "primary_publishing_organisation")
      create(:link, source: felling, target: dfe, link_type: "organisations")
    end

    scenario "filtering by organisation" do
      visit "/content/items"
      select "HMRC", from: "organisations"
      click_on "Filter"


      expect(page).to have_content("VAT")
    end

    scenario "the users previously filtered organisation is selected after filtering" do
      visit "/content/items"
      select "HMRC", from: "organisations"
      click_on "Filter"

      expect(page).to have_select(:organisations, selected: "HMRC")
    end
  end

  context "additional filters" do
    scenario "the user cannot see the additional filters by default", js: true do
      visit "/content/items"

      expect(page).to have_selector('#additionalFilters', visible: false)
    end

    scenario "the user can toggle the visibility of the additional filters", js: true do
      visit "/content/items"

      click_on "More filter options"

      expect(page).to have_selector('#additionalFilters', visible: true)
    end

    scenario "the user can see the additional filters if they are currently filtering by one of them", js: true do
      content = create(:content_item, title: "Ofsted report")
      taxonomy = create(:content_item, title: "Education")
      create(:link, source: content, target: taxonomy, link_type: "taxons")

      visit "/content/items?taxons=#{content.content_id}"

      expect(page).to have_selector('#additionalFilters', visible: true)
    end
  end
end
