RSpec.feature "Filter Content Items to Audit", type: :feature do
  before do
    create(:audit, content_item: create(:content_item, title: "Audited content item"))
    create(:content_item, title: "Non-audited content item")
  end

  scenario "List all content items (audited and not audited)" do
    visit audits_path

    expect(page).to have_content("Audited content item")
    expect(page).to have_content("Non-audited content item")
  end

  scenario "Filter audited content" do
    visit audits_path
    select "Audited", from: "audit_status"

    click_on "Filter"

    expect(page).to have_content("Audited content item")
    expect(page).to_not have_content("Non-audited content item")
    expect(page).to have_select("audit_status", selected: "Audited")
  end

  scenario "Filter non-audited content" do
    visit audits_path
    select "Non Audited", from: "audit_status"

    click_on "Filter"

    expect(page).to_not have_content("Audited content item")
    expect(page).to have_content("Non-audited content item")
    expect(page).to have_select("audit_status", selected: "Non Audited")
  end

  scenario "Reseting page to 1 after filtering" do
    FactoryGirl.create_list(:content_item, 25)

    visit audits_path
    within(".pagination") { click_on "2" }

    select "Non Audited", from: "audit_status"
    click_on "Filter"

    expect(page).to have_css(".pagination .active", text: "1")
  end
end
