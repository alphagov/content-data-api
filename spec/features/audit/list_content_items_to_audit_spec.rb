RSpec.feature "List Content Items to Audit", type: :feature do
  let!(:content_item_1) { create(:content_item, title: "All about flooding.") }
  let!(:content_item_2) { create(:content_item, title: "All about gardening.") }

  scenario "User does not see CPM feedback survey link in banner" do
    visit audits_path

    expect(page).to have_no_link("these quick questions")
  end

  scenario "List Content Items to Audit" do
    content_item_1.update!(six_months_page_views: 1234)

    visit audits_path

    expect(page).to have_content("All about flooding.")
    expect(page).to have_content("All about gardening.")
    expect(page).to have_content("1,234")
    expect(page).to have_link("All about gardening.", href: "/content_items/#{content_item_2.content_id}/audit")
  end

  scenario "Default sorting by popularity" do
    content_item_1.update!(six_months_page_views: 0)
    content_item_2.update!(six_months_page_views: 1234)

    visit audits_path

    rows = page.all('main tbody tr')
    expect(rows[0].text).to match("All about gardening.")
    expect(rows[1].text).to match("All about flooding.")
  end
end
