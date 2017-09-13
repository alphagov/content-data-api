RSpec.feature "Tabs" do
  scenario "reset filters on each tab" do
    visit audits_path
    expect(page).to have_select("allocated_to", selected: "Me")

    choose "Audited"
    select "Anyone", from: "allocated_to"
    click_on "Apply filters"
    expect(page).to have_select("allocated_to", selected: "Anyone")

    click_on "Assign content"
    expect(page).to have_select("allocated_to", selected: "No one")

    click_link "Audit progress"
    expect(page).to have_select("allocated_to", selected: "Me")

    select "Anyone", from: "allocated_to"
    click_link "Audit content"
    expect(page).to have_select("allocated_to", selected: "Me")
  end
end
