RSpec.feature "Filter content by allocated content auditor", type: :feature do
  let!(:me) do
    create(
      :user,
    )
  end

  scenario "Filter allocated content" do
    another_user = create(:user)
    item1 = create :content_item, title: "content item 1"
    item2 = create(:content_item, title: "content item 2")
    create(:content_item, title: "content item 3")

    create(:allocation, content_item: item1, user: me)
    create(:allocation, content_item: item2, user: another_user)

    visit audits_allocations_path

    expect(page).to have_selector(".nav")
    expect(page).to have_selector("#sort_by")

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

  scenario "Does not change filter status after user has allocated content" do
    create :content_item, title: "content item 1"
    item2 = create(:content_item, title: "content item 2")
    item3 = create(:content_item, title: "content item 3")

    create(:allocation, content_item: item2, user: me)

    visit audits_allocations_path

    select "No one", from: "allocated_to"
    click_on "Apply filters"

    check option: item3.content_id
    select "Me", from: "allocate_to"
    click_on "Assign"

    expect(page).to have_select("allocated_to", selected: "No one")

    expect(page).to_not have_content("content item 2")
    expect(page).to_not have_content("content item 3")
  end

  scenario "Filter content allocated to other content auditor" do
    user = create(:user, name: "John Smith")
    item1 = create :content_item, title: "content item 1"
    create :allocation, user: user, content_item: item1
    create :content_item, title: "content item 2"

    visit audits_allocations_path

    expect(page).to have_content("content item 1")
    expect(page).to have_content("content item 2")

    select "John Smith", from: "allocated_to"
    click_on "Apply filters"

    expect(page).to have_content("content item 1")
    expect(page).to_not have_content("content item 2")
  end

  scenario "Displays the number of content items" do
    create_list :content_item, 2

    visit audits_allocations_path

    expect(page).to have_text("2 items")
  end
end
