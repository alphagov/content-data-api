# rubocop:disable Style/VariableNumber
RSpec.feature "Managing inventory" do
  def node(title)
    FactoryGirl.create(:content_item, title: title)
  end

  def edge(from, to, type)
    FactoryGirl.create(:link, source: from, target: to, link_type: type)
  end

  def expect_active(title)
    expect(page).to have_css(".row.active", text: title)
  end

  def expect_inactive(title)
    expect(page).to have_css(".row", text: title)
    expect(page).to have_no_css(".row.active", text: title)
  end

  before do
    content_item_1 = node("Content Item 1")
    content_item_2 = node("Content Item 2")

    organisation_1 = node("Organisation 1")
    organisation_2 = node("Organisation 2")

    policy_area_1 = node("Policy Area 1")
    policy_area_2 = node("Policy Area 2")

    edge(content_item_1, organisation_1, "organisations")
    edge(content_item_2, organisation_1, "organisations")
    edge(content_item_2, organisation_2, "organisations")

    edge(content_item_1, policy_area_1, "policy_areas")
    edge(content_item_1, policy_area_2, "policy_areas")
    edge(content_item_2, policy_area_2, "policy_areas")
  end

  scenario "managing inventory rules for themes and subthemes" do
    visit inventory_root_path
    expect(page).to have_content("This page lets you manage themes and subthemes.")

    within ".themes" do
      fill_in "theme_name", with: "Environment"
      click_on "Add"
    end

    expect_active "Environment"

    within ".subthemes" do
      fill_in "subtheme_name", with: "Waste"
      click_on "Add"
    end

    expect_active "Waste"

    click_on "Organisations"
    expect_inactive "Organisation 1 (2)"
    expect_inactive "Organisation 2 (1)"

    click_on "Organisation 1 (2)"
    expect_active "Organisation 1 (2)"
    expect_inactive "Organisation 2 (1)"

    click_on "Organisation 1 (2)"
    expect_inactive "Organisation 1 (2)"
    expect_inactive "Organisation 2 (1)"

    click_on "Organisation 2 (1)"
    expect_inactive "Organisation 1 (2)"
    expect_active "Organisation 2 (1)"

    click_on "Policy Areas"
    expect_inactive "Policy Area 1 (1)"
    expect_inactive "Policy Area 2 (2)"

    click_on "Policy Area 1 (1)"
    expect_active "Policy Area 1 (1)"
    expect_inactive "Policy Area 2 (2)"

    within ".subthemes" do
      fill_in "subtheme_name", with: "Air pollution"
      click_on "Add"
    end

    expect_active("Air pollution")

    click_on "Organisations"
    expect_inactive "Organisation 1 (2)"
    expect_inactive "Organisation 2 (1)"

    click_on "Organisation 1 (2)"
    expect_active "Organisation 1 (2)"
    expect_inactive "Organisation 2 (1)"

    click_on "Waste"
    expect_inactive "Organisation 1 (2)"
    expect_active "Organisation 2 (1)"

    click_on "Policy Areas"
    expect_active "Policy Area 1 (1)"
    expect_inactive "Policy Area 2 (2)"

    click_on "Air pollution"
    expect_inactive "Policy Area 1 (1)"
    expect_inactive "Policy Area 2 (2)"
  end

  scenario "disabling columns when no theme or subtheme is selected" do
    visit inventory_root_path

    expect(page).to have_no_css(".themes.disabled")
    expect(page).to have_css(".subthemes.disabled")
    expect(page).to have_css(".criteria.disabled")
    expect(page).to have_css(".content.disabled")

    within ".themes" do
      fill_in "theme_name", with: "Environment"
      click_on "Add"
    end

    expect(page).to have_no_css(".themes.disabled")
    expect(page).to have_no_css(".subthemes.disabled")
    expect(page).to have_css(".criteria.disabled")
    expect(page).to have_css(".content.disabled")

    within ".subthemes" do
      fill_in "subtheme_name", with: "Waste"
      click_on "Add"
    end

    expect(page).to have_no_css(".themes.disabled")
    expect(page).to have_no_css(".subthemes.disabled")
    expect(page).to have_no_css(".criteria.disabled")
    expect(page).to have_no_css(".content.disabled")

    click_on "Organisations"

    within ".themes" do
      fill_in "theme_name", with: "Travel"
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
      fill_in "theme_name", with: "Environment"
      click_on "Add"
    end

    within ".subthemes" do
      fill_in "subtheme_name", with: "Waste"
      click_on "Add"
    end

    click_on "Organisations"
    expect_inactive "Organisation 1 (2)"
    expect_inactive "Organisation 2 (1)"

    click_on "Organisation 1 (2)"
    expect_active "Organisation 1 (2)"

    click_on "Organisation 1 (2)"
    expect_inactive "Organisation 1 (2)"

    click_on "Organisation 1 (2)"
    expect_active "Organisation 1 (2)"
  end
end
