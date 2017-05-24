RSpec.feature "List Content Items to Audit", type: :feature do
  let!(:user) { FactoryGirl.create(:user) }

  before do
    FactoryGirl.create(:content_item, title: "All about flooding.")
    FactoryGirl.create(:content_item, title: "All about gardening.", one_month_page_views: 1234)
  end

  scenario "List Content Items to Audit" do
    visit audits_path

    expect(page).to have_content("All about flooding.")
    expect(page).to have_content("All about gardening.")
    expect(page).to have_content("1234")
  end
end
