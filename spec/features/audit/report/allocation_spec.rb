RSpec.feature "Content Allocation", type: :feature do
  let!(:me) do
    create(
      :user,
    )
  end

  scenario "Filter allocated content" do
    content_item = create :content_item, title: "content item 1"

    create(:allocation, content_item: content_item, user: me)

    visit audits_report_path

    select "Me", from: "allocated_to"
    click_on "Apply filters"
    expect(page).to have_selector(".report-section", text: "1")

    select "No one", from: "allocated_to"
    click_on "Apply filters"
    expect(page).to have_selector(".report-section", text: "0")
  end
end
