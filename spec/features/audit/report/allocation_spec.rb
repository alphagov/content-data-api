RSpec.feature "Content Allocation", type: :feature do
  let!(:my_organisation) do
    create(
      :organisation,
    )
  end

  let!(:me) do
    create(
      :user,
      organisation: my_organisation,
    )
  end

  scenario "Filter allocated content" do
    create(
      :content_item,
      title: "Do Androids Dream of Electric Sheep",
      allocated_to: me,
      primary_publishing_organisation: my_organisation,
    )

    visit audits_report_path

    expect(page).to have_selector(".report-section", text: "1")

    select "No one", from: "allocated_to"
    click_on "Apply filters"
    expect(page).to have_selector(".report-section", text: "0")
  end
end
