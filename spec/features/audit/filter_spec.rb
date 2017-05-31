RSpec.feature "Filter Content Items to Audit", type: :feature do
  let!(:user) { FactoryGirl.create(:user) }

  let!(:content_item_audited) { FactoryGirl.create(:content_item, title: "Title of Audited content item") }
  let!(:content_item_not_audited) { FactoryGirl.create(:content_item, title: "Title of Non-Audited content item") }

  let!(:audit) { FactoryGirl.create(:audit, content_item: content_item_audited) }

  scenario "List all content items (audited and not audited)" do
    visit audits_path

    expect(page).to have_content("Title of Audited content item")
    expect(page).to have_content("Title of Non-Audited content item")
  end

  scenario "Filter audited content" do
    visit audits_path
    select "Audited", from: "audit_status"

    click_on "Filter"

    expect(page).to have_content("Title of Audited content item")
    expect(page).to_not have_content("Title of Non-Audited content item")
    expect(page).to have_select("audit_status", selected: "Audited")
  end

  scenario "Filter non-audited content" do
    visit audits_path
    select "Non Audited", from: "audit_status"

    click_on "Filter"

    expect(page).to_not have_content("Title of Audited content item")
    expect(page).to have_content("Title of Non-Audited content item")
    expect(page).to have_select("audit_status", selected: "Non Audited")
  end
end
