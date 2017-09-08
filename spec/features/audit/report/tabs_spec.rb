RSpec.feature "Tabs" do
  scenario "preserving filters across tabs" do
    visit audits_path
    choose "Audited"

    click_on "Apply filters"
    expect(page).to have_checked_field("audit_status_audited")

    click_link "Audit progress"

    click_link "Audit content"
    expect(page).to have_checked_field("audit_status_audited")
  end
end
