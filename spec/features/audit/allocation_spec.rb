RSpec.feature "Content Allocation", type: :feature do
  let(:content_item) { create :content_item, title: "content item 1" }

  scenario "Filter allocated content" do
    current_user = User.first
    another_user = create(:user)
    another_content_item = create(:content_item, title: "content item 2")
    create(:content_item, title: "content item 3")

    create(:allocation, content_item: content_item, user: current_user)
    create(:allocation, content_item: another_content_item, user: another_user)

    visit audits_path
    expect(page).to have_content("content item 1")
    expect(page).to have_content("content item 2")

    select "Me", from: "allocated_to"
    click_on "Filter"
    expect(page).to have_content("content item 1")
    expect(page).to_not have_content("content item 2")

    select "No one", from: "allocated_to"
    click_on "Filter"
    expect(page).to_not have_content("content item 1")
    expect(page).to_not have_content("content item 2")
    expect(page).to have_content("content item 3")

    select "Anyone", from: "allocated_to"
    click_on "Filter"
    expect(page).to have_content("content item 1")
    expect(page).to have_content("content item 2")
    expect(page).to have_content("content item 3")
  end
end
