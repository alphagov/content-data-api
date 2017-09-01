RSpec.feature "Allocate content to other content auditors", type: :feature do
  around(:each) do |example|
    Feature.run_with_activated(:auditing_allocation) { example.run }
  end

  scenario "List allocation options including other content auditors" do
    create :user, name: "John Smith"

    visit audits_allocations_path

    options = [
      "Me",
      "Anyone",
      "No one",
      "John Smith",
    ]
    expect(page).to have_select("allocated_to", options: options)
  end

  scenario "Allocate content to other content auditors" do
    create(:user, name: "John Smith")
    item1 = create :content_item, title: "content item 1"
    create(:content_item, title: "content item 2")

    visit audits_allocations_path

    check option: item1.content_id

    select "John Smith", from: "allocate_to"
    click_on "Go"

    expect(page).to have_content("1 items allocated to John Smith")

    select "John Smith", from: "allocated_to"
    click_on "Apply filters"

    expect(page).to have_content("content item 1")
    expect(page).to_not have_content("content item 2")
  end
end
