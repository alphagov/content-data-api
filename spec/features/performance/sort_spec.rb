RSpec.feature "Sort Content Items", type: :feature do
  before do
    create(:user)
  end

  scenario "sort by number of views in the last 6 months" do
    create :content_item, title: "very popular", six_months_page_views: 1000
    create :content_item, title: "non-popular", six_months_page_views: 0
    create :content_item, title: "popular", six_months_page_views: 100

    visit "/content/items"

    click_on "Filter"

    expect(page).to have_selector("main tbody tr", count: 3)
    expect(page).to have_selector("main tbody tr:nth-child(1)", text: "very popular")
    expect(page).to have_selector("main tbody tr:nth-child(2)", text: "popular")
    expect(page).to have_selector("main tbody tr:nth-child(3)", text: "non-popular")
  end

  scenario "sort by title" do
    create :content_item, title: "CCC"
    create :content_item, title: "AAA"
    create :content_item, title: "BBB"

    visit "/content/items"

    within("table tr.table-header") { click_on "Title" }

    expect(page).to have_selector("main tbody tr", count: 3)
    expect(page).to have_selector("main tbody tr:nth-child(1)", text: "AAA")
    expect(page).to have_selector("main tbody tr:nth-child(2)", text: "BBB")
    expect(page).to have_selector("main tbody tr:nth-child(3)", text: "CCC")

    within("table tr.table-header") { click_on "Title" }

    expect(page).to have_selector("main tbody tr", count: 3)
    expect(page).to have_selector("main tbody tr:nth-child(1)", text: "CCC")
    expect(page).to have_selector("main tbody tr:nth-child(2)", text: "BBB")
    expect(page).to have_selector("main tbody tr:nth-child(3)", text: "AAA")
  end
end
