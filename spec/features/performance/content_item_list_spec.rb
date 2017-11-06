RSpec.feature "Content Items List", type: :feature do
  before do
    create(:user)
  end

  scenario "User does can see CPM feedback survey link in banner" do
    visit "/content/items"

    expect(page).to have_link("these quick questions")
  end

  scenario "Renders the table header" do
    visit "/content/items"

    expect(page).to have_selector('thead', text: 'Title')
    expect(page).to have_selector('thead tr:first-child th', text: 'Doc type')
    expect(page).to have_selector('thead tr:first-child th', text: 'Page views (1 month)')
    expect(page).to have_selector('thead tr:first-child th', text: 'Last major update')
  end

  scenario "Renders content item details" do
    create(:content_item,
      title: "a-title",
      document_type: "guide",
      one_month_page_views: "99",
      public_updated_at: 2.months.ago)

    visit "/content/items"

    expect(page).to have_text("a-title")
    expect(page).to have_text("Guide")
    expect(page).to have_text("99")
    expect(page).to have_text("2 months ago")
  end

  scenario "Renders all content items" do
    create_list :content_item, 2

    visit "/content/items"

    expect(page).to have_selector('table tbody tr', count: 2)
  end

  scenario "Paginate through content items" do
    create_list(:content_item, 101)

    visit "/content/items"
    expect(page).to have_selector("main tbody tr", count: 100)

    within(".pagination") { click_on "2" }

    expect(page).to have_selector("main tbody tr", count: 1)
  end
end
