RSpec.feature "Allocate multiple content items", type: :feature do
  let!(:content_item) { create :content_item, title: "content item 1" }
  let!(:current_user) { User.first }

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

  scenario "Allocate 0 content items" do
    visit audits_allocations_path

    select "Me", from: "allocate_to"
    click_on "Go"

    expect(page).to have_content("0 items allocated to #{current_user.name}")
  end
end
