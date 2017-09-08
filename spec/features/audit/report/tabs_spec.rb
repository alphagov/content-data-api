RSpec.feature "Tabs" do
  scenario "preserving filters across tabs" do
    visit audits_path
    select "Audited", from: "audit_status"

    click_on "Apply filters"
    expect(page).to have_select("audit_status", selected: "Audited")

    click_link "Audit progress"

    click_link "Audit content"
    expect(page).to have_select("audit_status", selected: "Audited")
  end
end
