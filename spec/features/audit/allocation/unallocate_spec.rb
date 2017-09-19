RSpec.feature "Unallocate content", type: :feature do
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

  let!(:content_item) { create :content_item, title: "content item 1" }

  context "There are two content items allocated to me" do
    let!(:winnie_the_pooh) do
      create(
        :content_item,
        title: "Winnie the Pooh",
        content_id: "winnie-the-pooh",
        allocated_to: me,
        primary_publishing_organisation: my_organisation,
      )
    end

    let!(:eeyore) do
      create(
        :content_item,
        title: "Eeyore",
        content_id: "eeyore",
        allocated_to: me,
        primary_publishing_organisation: my_organisation,
      )
    end

    before(:each) do
      visit audits_allocations_path

      select "Me", from: "allocated_to"
      click_on "Apply filters"

      expect(page).to have_content("Winnie the Pooh")
      expect(page).to have_content("Eeyore")
    end

    scenario "Unallocate content" do
      check option: "winnie-the-pooh"
      select "No one", from: "allocate_to"
      click_on "Assign"

      expect(page).to_not have_content("Winnie the Pooh")
      expect(page).to have_select("allocate_to", selected: "No one")
      expect(page).to have_content("1 item assigned to no one")
    end

    scenario "Allocate using the batch input" do
      select "No one", from: "allocate_to"
      fill_in "batch_size", with: "2"
      click_on "Assign"

      expect(page).to have_content("2 items assigned to no one")
      expect(page).to_not have_content("Winnie the Pooh")
      expect(page).to_not have_content("Eeyore")
    end

    scenario "Allocate selecting individual items" do
      check option: "winnie-the-pooh"
      check option: "eeyore"

      select "No one", from: "allocate_to"
      click_on "Assign"

      expect(page).to have_content("2 items assigned to no one")
      expect(page).to_not have_content("Winnie the Pooh")
      expect(page).to_not have_content("Eeyore")
    end
  end

  scenario "Unallocate 0 content items" do
    visit audits_allocations_path

    select "No one", from: "allocate_to"
    click_on "Assign"

    expect(page).to have_content("You did not select any content to be assigned")
  end
end
