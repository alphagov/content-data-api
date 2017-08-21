RSpec.feature "Content Allocation", type: :feature do
  around(:each) do |example|
    Feature.run_with_activated(:auditing_allocation) { example.run }
  end

  let!(:content_item) { create :content_item, title: "content item 1" }
  let!(:current_user) { User.first }

  scenario "Filter allocated content" do
    another_user = create(:user)
    another_content_item = create(:content_item, title: "content item 2")
    create(:content_item, title: "content item 3")

    create(:allocation, content_item: content_item, user: current_user)
    create(:allocation, content_item: another_content_item, user: another_user)

    visit audits_path
    expect(page).to have_content("content item 1")
    expect(page).to have_content("content item 2")

    select "Me", from: "allocated_to"
    click_on "Apply filters"
    expect(page).to have_content("content item 1")
    expect(page).to_not have_content("content item 2")

    select "No one", from: "allocated_to"
    click_on "Apply filters"
    expect(page).to_not have_content("content item 1")
    expect(page).to_not have_content("content item 2")
    expect(page).to have_content("content item 3")

    select "Anyone", from: "allocated_to"
    click_on "Apply filters"
    expect(page).to have_content("content item 1")
    expect(page).to have_content("content item 2")
    expect(page).to have_content("content item 3")
  end

  scenario "Allocate content within current page" do
    second = create(:content_item, title: "content item 2")
    first = create(:content_item, title: "content item 3")

    visit audits_allocations_path

    check option: second.content_id
    check option: first.content_id

    select "Me", from: "allocate_to"
    click_on "Go"

    expect(page).to have_content("2 items allocated to #{current_user.name}")

    select "Me", from: "allocated_to"
    click_on "Apply filters"

    expect(page).to_not have_content("content item 1")
    expect(page).to have_content("content item 2")
    expect(page).to have_content("content item 3")

    select "No one", from: "allocated_to"
    click_on "Apply filters"

    expect(page).to have_content("content item 1")
    expect(page).to_not have_content("content item 2")
    expect(page).to_not have_content("content item 3")
  end

  scenario "Does not change filer status after user has allocated content" do
    item2 = create(:content_item, title: "content item 2")
    item3 = create(:content_item, title: "content item 3")

    create(:allocation, content_item: item2, user: current_user)

    visit audits_allocations_path

    select "No one", from: "allocated_to"
    click_on "Apply filters"

    check option: item3.content_id
    select "Me", from: "allocate_to"
    click_on "Go"

    expect(page).to_not have_content("content item 2")
    expect(page).to_not have_content("content item 3")

    expect(page).to have_select("allocated_to", selected: "No one")
  end

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

  scenario 'Allocate all content within current page', :js do
    create_list(:content_item, 26)

    visit audits_allocations_path

    check 'Select all'

    select 'Me', from: 'allocate_to'
    click_on 'Go'

    within('.alert-success') do
      expect(page).to have_content("25 items allocated to #{current_user.name}")
    end
  end

  scenario 'Allocate all content within all pages', :js do
    create_list(:content_item, 26)

    visit audits_allocations_path

    check 'Select all'
    check 'Select 27 items on all pages'

    select 'Me', from: 'allocate_to'
    click_on 'Go'

    within('.alert-success') do
      expect(page).to have_content("27 items allocated to #{current_user.name}")
    end
  end
end
