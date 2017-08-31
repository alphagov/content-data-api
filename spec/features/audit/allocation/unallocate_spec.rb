RSpec.feature "Unallocate content", type: :feature do
  around(:each) do |example|
    Feature.run_with_activated(:auditing_allocation) { example.run }
  end

  let!(:content_item) { create :content_item, title: "content item 1" }
  let!(:current_user) { User.first }

  scenario "Unallocate content" do
    create(:allocation, content_item: content_item, user: current_user)

    visit audits_allocations_path

    select "Me", from: "allocated_to"
    click_on "Apply filters"
    expect(page).to have_content("content item 1")


    check option: content_item.content_id
    select "No one", from: "allocate_to"
    click_on "Go"

    expect(page).to_not have_content("content item 1")
    expect(page).to have_select("allocate_to", selected: "No one")
    expect(page).to have_content("1 items unallocated")
  end
end
