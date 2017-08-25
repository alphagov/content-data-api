RSpec.feature "Content Allocation", type: :feature do
  around(:each) do |example|
    Feature.run_with_activated(:auditing_allocation) { example.run }
  end

  scenario "Filter allocated content" do
    current_user = User.first
    content_item = create :content_item, title: "content item 1"

    create(:allocation, content_item: content_item, user: current_user)

    visit audits_report_path

    select "Me", from: "allocated_to"
    click_on "Apply filters"
    expect(page).to have_selector(".report-section", text: "1")

    select "No one", from: "allocated_to"
    click_on "Apply filters"
    expect(page).to have_selector(".report-section", text: "0")
  end
end
