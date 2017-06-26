RSpec.feature "Auditing a content item", type: :feature do
  scenario "visiting the guidance page" do
    visit "/audit-guidance"

    expect(page).to have_css("h1")
    expect(page).to have_content("Audit GOV.UK content")
  end
end
