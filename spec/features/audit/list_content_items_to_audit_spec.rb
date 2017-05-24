RSpec.feature "List Content Items to Audit", type: :feature do
  let!(:user) {FactoryGirl.create(:user)}

  before do
    FactoryGirl.create(:content_item, title: "All about flooding.")
  end

  let!(:content_item) { FactoryGirl.create(:content_item, title: "All about gardening.", one_month_page_views: 1234) }

  scenario "List Content Items to Audit" do
    visit audits_path

    expect(page).to have_content("All about flooding.")
    expect(page).to have_content("All about gardening.")
    expect(page).to have_content("1234")
    expect(page).to have_link("All about gardening.", href: "/content_items/#{content_item.id}/audit")
  end
end
