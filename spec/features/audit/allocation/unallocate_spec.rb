RSpec.feature "Unallocate content", type: :feature do
  let!(:me) do
    create(
      :user,
    )
  end

  let!(:content_item) { create :content_item, title: "content item 1" }

  scenario "Unallocate content" do
    create(:allocation, content_item: content_item, user: me)

    visit audits_allocations_path

    select "Me", from: "allocated_to"
    click_on "Apply filters"
    expect(page).to have_content("content item 1")


    check option: content_item.content_id
    select "No one", from: "allocate_to"
    click_on "Assign"

    expect(page).to_not have_content("content item 1")
    expect(page).to have_select("allocate_to", selected: "No one")
    expect(page).to have_content("1 items unallocated")
  end

  scenario "Allocate using the batch input" do
    create_list :content_item, 2

    visit audits_allocations_path

    select "No one", from: "allocate_to"
    fill_in "batch_size", with: "2"
    click_on "Assign"

    expect(page).to have_content("2 items unallocated")
  end

  scenario "Allocate selecting individual items" do
    item2 = create(:content_item, title: "content item 2")
    item3 = create(:content_item, title: "content item 3")

    visit audits_allocations_path

    check option: item2.content_id
    check option: item3.content_id

    select "No one", from: "allocate_to"
    click_on "Assign"

    expect(page).to have_content("2 items unallocated")
  end

  scenario "Unallocate 0 content items" do
    visit audits_allocations_path

    select "No one", from: "allocate_to"
    click_on "Assign"

    expect(page).to have_content("0 items unallocated")
  end
end
