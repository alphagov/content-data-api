RSpec.feature "Filter Content Items to Audit", type: :feature do
  before do
    audited = FactoryGirl.create(:content_item, title: "Audited content item")
    FactoryGirl.create(:audit, content_item: audited)

    non_audited = FactoryGirl.create(:content_item, title: "Non-audited content item")

    hmrc = FactoryGirl.create(:content_item, title: "HMRC")
    FactoryGirl.create(:link, source: audited, target: hmrc, link_type: "organisations")

    dfe = FactoryGirl.create(:content_item, title: "DFE")
    FactoryGirl.create(:link, source: non_audited, target: dfe, link_type: "organisations")

    FactoryGirl.create(:subtheme, name: "Environment")
    travel = FactoryGirl.create(:subtheme, name: "Travel")

    travel_insurance = FactoryGirl.create(:content_item, title: "Travel insurance advice for theme of flying abroad")
    flying_abroad = FactoryGirl.create(:content_item, title: "Flying to countries abroad")
    FactoryGirl.create(:link, source: travel_insurance, target: flying_abroad, link_type: "policies")
    FactoryGirl.create(
      :inventory_rule,
      subtheme: travel,
      link_type: "policies",
      target_content_id: flying_abroad.content_id,
    )
  end

  scenario "List all content items (audited and not audited)" do
    visit audits_path

    expect(page).to have_content("Audited content item")
    expect(page).to have_content("Non-audited content item")
  end

  scenario "Filter audited content" do
    visit audits_path
    select "Audited", from: "audit_status"

    click_on "Filter"

    expect(page).to have_content("Audited content item")
    expect(page).to have_no_content("Non-audited content item")
    expect(page).to have_select("audit_status", selected: "Audited")
  end

  scenario "Filter non-audited content" do
    visit audits_path
    select "Non Audited", from: "audit_status"

    click_on "Filter"

    expect(page).to have_no_content("Audited content item")
    expect(page).to have_content("Non-audited content item")
    expect(page).to have_select("audit_status", selected: "Non Audited")
  end

  scenario "filtering by organisation" do
    visit audits_path
    select "HMRC", from: "organisations"

    click_on "Filter"

    expect(page).to have_content("Audited content item")
    expect(page).to have_no_content("Non-audited content item")

    expect(page).to have_content("HMRC (1)")
    expect(page).to have_content("DFE (1)")

    select "Audited", from: "audit_status"

    click_on "Filter"
    expect(page).to have_content("HMRC (1)")
    expect(page).to have_content("DFE (0)")
  end

  scenario "subthemes are in alphabetical order" do
    visit audits_path

    within("#subtheme") do
      options = page.all("option")
      subthemes = options.map(&:text)

      expect(subthemes).to eq %w(All Environment Travel)
    end
  end

  scenario "filtering by subtheme" do
    visit audits_path
    select "Travel", from: "subtheme"

    click_on "Filter"

    within("table") do
      expect(page).to have_content("Travel insurance advice for theme of flying abroad")
      expect(page).to have_no_content("Flying to countries abroad")
      expect(page).to have_no_content("DFE")
    end
  end

  scenario "Reseting page to 1 after filtering" do
    FactoryGirl.create_list(:content_item, 25)

    visit audits_path
    within(".pagination") { click_on "2" }

    select "Non Audited", from: "audit_status"
    click_on "Filter"

    expect(page).to have_css(".pagination .active", text: "1")
  end
end
