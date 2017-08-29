RSpec.feature "Sort content items to audit", type: :feature do
  scenario "Default sorting by popularity" do
    content_items[0].update!(six_months_page_views: 0)
    content_items[1].update!(six_months_page_views: 1234)

    visit audits_path

    rows = page.all('main tbody tr')
    expect(rows[0].text).to match(content_items[1].title)
    expect(rows[1].text).to match(content_items[0].title)
  end
end
