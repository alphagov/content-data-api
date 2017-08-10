# rubocop:disable Style/VariableNumber
RSpec.feature "Managing inventory" do
  before do
    User.first.update!(
      uid: "user-99",
      name: "Test User",
      organisation_slug: "government-digital-service",
      permissions: %w(inventory_management),
    )
  end

  def expect_active(title)
    expect(page).to have_css(".row.active", text: title)
  end

  def expect_inactive(title)
    expect(page).to have_css(".row", text: title)
    expect(page).to have_no_css(".row.active", text: title)
  end

  before do
    organisation_1 = create(:content_item, title: "Organisation 1")
    organisation_2 = create(:content_item, title: "Organisation 2")

    policy_area_1 = create(:content_item, title: "Policy Area 1")
    policy_area_2 = create(:content_item, title: "Policy Area 2")

    create(
      :content_item,
      title: "Content Item 1",
      organisations: organisation_1,
      policy_areas: [policy_area_1, policy_area_2],
    )

    create(
      :content_item,
      title: "Content Item 2",
      organisations: [organisation_1, organisation_2],
      policy_areas: [policy_area_2]
    )
  end

  scenario "managing inventory rules for themes and subthemes" do
    visit inventory_root_path
    expect(page).to have_content("This page lets you manage themes and subthemes.")

    within ".themes" do
      fill_in "audits_theme_name", with: "Environment"
      click_on "Add"
    end

    expect_active "Environment"

    within ".subthemes" do
      fill_in "audits_subtheme_name", with: "Waste"
      click_on "Add"
    end

    expect_active "Waste"

    click_on "Organisations"
    expect_inactive "Organisation 1"
    expect_inactive "Organisation 2"

    click_on "Organisation 1"
    expect_active "Organisation 1"
    expect_inactive "Organisation 2"

    click_on "Organisation 1"
    expect_inactive "Organisation 1"
    expect_inactive "Organisation 2"

    click_on "Organisation 2"
    expect_inactive "Organisation 1"
    expect_active "Organisation 2"

    click_on "Policy Areas"
    expect_inactive "Policy Area 1"
    expect_inactive "Policy Area 2"

    click_on "Policy Area 1"
    expect_active "Policy Area 1"
    expect_inactive "Policy Area 2"

    within ".subthemes" do
      fill_in "audits_subtheme_name", with: "Air pollution"
      click_on "Add"
    end

    expect_active("Air pollution")

    click_on "Organisations"
    expect_inactive "Organisation 1"
    expect_inactive "Organisation 2"

    click_on "Organisation 1"
    expect_active "Organisation 1"
    expect_inactive "Organisation 2"

    click_on "Waste"
    expect_inactive "Organisation 1"
    expect_active "Organisation 2"

    click_on "Policy Areas"
    expect_active "Policy Area 1"
    expect_inactive "Policy Area 2"

    click_on "Air pollution"
    expect_inactive "Policy Area 1"
    expect_inactive "Policy Area 2"
  end

  scenario "disabling columns when no theme or subtheme is selected" do
    visit inventory_root_path

    expect(page).to have_no_css(".themes.disabled")
    expect(page).to have_css(".subthemes.disabled")
    expect(page).to have_css(".criteria.disabled")
    expect(page).to have_css(".content.disabled")

    within ".themes" do
      fill_in "audits_theme_name", with: "Environment"
      click_on "Add"
    end

    expect(page).to have_no_css(".themes.disabled")
    expect(page).to have_no_css(".subthemes.disabled")
    expect(page).to have_css(".criteria.disabled")
    expect(page).to have_css(".content.disabled")

    within ".subthemes" do
      fill_in "audits_subtheme_name", with: "Waste"
      click_on "Add"
    end

    expect(page).to have_no_css(".themes.disabled")
    expect(page).to have_no_css(".subthemes.disabled")
    expect(page).to have_no_css(".criteria.disabled")
    expect(page).to have_no_css(".content.disabled")

    click_on "Organisations"

    within ".themes" do
      fill_in "audits_theme_name", with: "Travel"
      click_on "Add"
    end

    expect(page).to have_no_css(".themes.disabled")
    expect(page).to have_no_css(".subthemes.disabled")
    expect(page).to have_css(".criteria.disabled")
    expect(page).to have_css(".content.disabled")
  end

  scenario "toggling content items more quickly with ajax", js: true do
    visit inventory_root_path

    within ".themes" do
      fill_in "audits_theme_name", with: "Environment"
      click_on "Add"
    end

    within ".subthemes" do
      fill_in "audits_subtheme_name", with: "Waste"
      click_on "Add"
    end

    click_on "Organisations"
    expect_inactive "Organisation 1"
    expect_inactive "Organisation 2"

    click_on "Organisation 1"
    expect_active "Organisation 1"

    click_on "Organisation 1"
    expect_inactive "Organisation 1"

    click_on "Organisation 1"
    expect_active "Organisation 1"
  end

  scenario "disallowing users without the inventory_management permission" do
    User.last.update!(permissions: %w(signin))

    visit inventory_root_path

    expect(page).not_to have_content("This page lets you manage themes and subthemes.")
    expect(page).to have_content("Sorry, you don't seem to have the inventory_management permission")
  end
end
