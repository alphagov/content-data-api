RSpec.feature "Tabs" do
  scenario "preserving filters across tabs" do
    visit audits_path
    select "Audited", from: "audit_status"

    click_on "Filter"
    expect(page).to have_select("audit_status", selected: "Audited")

    click_link "Report"

    click_link "Content"
    expect(page).to have_select("audit_status", selected: "Audited")
  end
end
