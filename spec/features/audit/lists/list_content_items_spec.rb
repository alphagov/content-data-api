RSpec.feature "List Content Items to Audit", type: :feature do
  let!(:content_items) {
    create_list(:content_item, 30)
      .sort_by(&:base_path)
      .reverse
  }

  scenario "User does not see CPM feedback survey link in banner" do
    visit audits_path

    expect(page).to have_no_link("these quick questions")
  end

  scenario "List Content Items to Audit" do
    content_items[0].update!(six_months_page_views: 1234)

    visit audits_path

    expect(page).to have_content(content_items[0].title)
    expect(page).to have_content(content_items[1].title)
    expect(page).to have_content("1,234")
    expect(page).to have_link(content_items[1].title, href: "/content_items/#{content_items[1].content_id}/audit")
  end

  scenario "Default sorting by popularity" do
    content_items[0].update!(six_months_page_views: 0)
    content_items[1].update!(six_months_page_views: 1234)

    visit audits_path

    rows = page.all('main tbody tr')
    expect(rows[0].text).to match(content_items[1].title)
    expect(rows[1].text).to match(content_items[0].title)
  end

  scenario "Showing 25 items on the first page" do
    visit audits_path

    content_items[0..24].each do |content_item|
      expect(page).to have_content(content_item.title)
    end

    content_items[25..29].each do |content_item|
      expect(page).to have_no_content(content_item.title)
    end
  end

  scenario "Showing the second page of items" do
    visit audits_path

    click_link "Next →"

    content_items[0..24].each do |content_item|
      expect(page).to have_no_content(content_item.title)
    end

    content_items[25..29].each do |content_item|
      expect(page).to have_content(content_item.title)
    end
  end

  scenario "Clicking 'Next' on content items" do
    visit audits_path

    click_link content_items[0].title

    (content_items.count - 1).times do |index|
      expect(page).to have_content(content_items[index].title)
      click_link "Next"
    end

    expect(page).to have_content(content_items.last.title)
    expect(page).to have_no_content "Next"
  end
end
