RSpec.feature "Sort content items to audit", type: :feature do
  scenario "Default sorting by popularity" do
    create(:content_item, six_months_page_views: 0, title: "item1")
    create(:content_item, six_months_page_views: 1234, title: "item2")

    visit audits_path

    rows = page.all('main tbody tr')
    expect(rows[0].text).to match("item2")
    expect(rows[1].text).to match("item1")
  end
end
