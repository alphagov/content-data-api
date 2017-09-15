RSpec.feature "Filter content by allocated content auditor", type: :feature do
  let!(:authors) do
    create(
      :organisation,
      title: "Authors",
    )
  end

  let!(:me) do
    create(
      :user,
      organisation: authors,
    )
  end

  context "There are some allocated and unallocated content items belonging to my organisation" do
    let!(:gabriel_garcia_marquez) do
      create(
        :user,
        name: "Gabriel Garcia Marquez",
        organisation: authors,
      )
    end

    let!(:painters) do
      create(
        :organisation,
        title: "Painters",
      )
    end

    let!(:love_in_the_time_of_cholera) do
      create(
        :content_item,
        title: "Love in the Time of Cholera",
        content_id: "love-in-the-time-of-cholera",
        allocated_to: me,
        primary_publishing_organisation: authors,
      )
    end

    let!(:one_hundred_years_of_solitude) do
      create(
        :content_item,
        title: "One Hundred Years of Solitude",
        allocated_to: gabriel_garcia_marquez,
        primary_publishing_organisation: authors,
      )
    end

    let!(:leaf_storm) do
      create(
        :content_item,
        title: "Leaf Storm",
        primary_publishing_organisation: authors,
      )
    end

    let!(:girl_with_the_pearl_earring) do
      create(
        :content_item,
        title: "Girl with a Pearl Earring",
        primary_publishing_organisation: painters,
      )
    end

    scenario "The filters default to unaudited content in my organisation allocated to no one" do
      visit audits_allocations_path

      expect(page).to have_select("allocated_to", selected: "No one")
      expect(page).to have_checked_field("audit_status_non_audited")
      expect(page).to have_select("organisations[]", selected: "Authors")

      expect(page).to have_no_content("Love in the Time of Cholera")
      expect(page).to have_no_content("One Hundred Years of Solitude")
      expect(page).to have_content("Leaf Storm")
      expect(page).to have_no_content("Girl with a Pearl Earring")
    end

    scenario "Filter allocated content" do
      visit audits_allocations_path

      select "Me", from: "allocated_to"
      click_on "Apply filters"
      expect(page).to have_content("Love in the Time of Cholera")
      expect(page).to have_no_content("One Hundred Years of Solitude")
      expect(page).to have_no_content("Leaf Storm")
      expect(page).to have_no_content("Girl with a Pearl Earring")

      select "No one", from: "allocated_to"
      click_on "Apply filters"
      expect(page).to have_no_content("Love in the Time of Cholera")
      expect(page).to have_no_content("One Hundred Years of Solitude")
      expect(page).to have_content("Leaf Storm")
      expect(page).to have_no_content("Girl with a Pearl Earring")

      select "Anyone", from: "allocated_to"
      click_on "Apply filters"
      expect(page).to have_content("Love in the Time of Cholera")
      expect(page).to have_content("One Hundred Years of Solitude")
      expect(page).to have_content("Leaf Storm")
      expect(page).to have_no_content("Girl with a Pearl Earring")
    end

    scenario "Does not change filter status after user has allocated content" do
      visit audits_allocations_path

      select "Me", from: "allocated_to"
      click_on "Apply filters"

      check option: "love-in-the-time-of-cholera"
      select "No one", from: "allocate_to"
      click_on "Assign"

      expect(page).to have_select("allocated_to", selected: "Me")

      expect(page).to have_no_content("Love in the Time of Cholera")
    end

    scenario "Filter content allocated to other content auditor" do
      visit audits_allocations_path

      select "Gabriel Garcia Marquez", from: "allocated_to"
      click_on "Apply filters"

      expect(page).to have_content("One Hundred Years of Solitude")
      expect(page).to_not have_content("Love in the Time of Cholera")
    end

    scenario "Displays the number of content items" do
      visit audits_allocations_path

      expect(page).to have_text("1 item")
    end
  end
end
