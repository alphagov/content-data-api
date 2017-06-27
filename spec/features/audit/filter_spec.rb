RSpec.feature "Filter Content Items to Audit", type: :feature do
  # Organisations:
  let!(:hmrc) { FactoryGirl.create(:content_item, title: "HMRC") }
  let!(:dfe) { FactoryGirl.create(:content_item, title: "DFE") }

  # Policies:
  let!(:flying) { FactoryGirl.create(:content_item, title: "Flying abroad") }
  let!(:insurance) { FactoryGirl.create(:content_item, title: "Travel insurance") }

  # Content:
  let!(:felling) { FactoryGirl.create(:content_item, title: "Tree felling") }
  let!(:management) { FactoryGirl.create(:content_item, title: "Forest management") }
  let!(:vat) { FactoryGirl.create(:content_item, title: "VAT") }

  # Audit:
  let!(:audit) { FactoryGirl.create(:audit, content_item: felling) }

  # Themes:
  let!(:travel) { FactoryGirl.create(:theme, name: "Travel") }
  let!(:environment) { FactoryGirl.create(:theme, name: "Environment") }

  # Subthemes:
  let!(:aviation) { FactoryGirl.create(:subtheme, theme: travel, name: "Aviation") }
  let!(:forestry) { FactoryGirl.create(:subtheme, theme: environment, name: "Forestry") }
  let!(:pollution) { FactoryGirl.create(:subtheme, theme: environment, name: "Air pollution") }

  before do
    # Links:
    FactoryGirl.create(:link, source: vat, target: hmrc, link_type: "organisations")
    FactoryGirl.create(:link, source: felling, target: dfe, link_type: "organisations")
    FactoryGirl.create(:link, source: insurance, target: flying, link_type: "policies")
    FactoryGirl.create(:link, source: felling, target: management, link_type: "policies")

    # Rules:
    FactoryGirl.create(:inventory_rule, subtheme: aviation, link_type: "policies", target_content_id: flying.content_id)
    FactoryGirl.create(:inventory_rule, subtheme: forestry, link_type: "policies", target_content_id: management.content_id)
  end

  scenario "List all content items (audited and not audited)" do
    visit audits_path

    expect(page).to have_content("Tree felling")
    expect(page).to have_content("Forest management")
  end

  scenario "filtering audited content" do
    visit audits_path
    select "Audited", from: "audit_status"

    click_on "Filter"

    expect(page).to have_content("Tree felling")
    expect(page).to have_no_content("Forest management")
    expect(page).to have_select("audit_status", selected: "Audited")
  end

  scenario "filtering non-audited content" do
    visit audits_path
    select "Non Audited", from: "audit_status"

    click_on "Filter"

    expect(page).to have_no_content("Tree felling")
    expect(page).to have_content("Forest management")
    expect(page).to have_select("audit_status", selected: "Non Audited")
  end

  scenario "filtering by organisation" do
    visit audits_path
    select "HMRC", from: "organisations"

    click_on "Filter"

    expect(page).to have_content("VAT")
    expect(page).to have_no_content("Tree felling")

    expect(page).to have_content("HMRC (1)")
    expect(page).to have_content("DFE (1)")

    select "Audited", from: "audit_status"

    click_on "Filter"
    expect(page).to have_no_content("HMRC (0)")
    expect(page).to have_content("DFE (1)")
  end

  scenario "organisations are in alphabetical order" do
    visit audits_path

    within("#organisations") do
      options = page.all("option")

      expect(options.map(&:text)).to eq [
        "All", "DFE (1)", "HMRC (1)",
      ]
    end
  end

  scenario "themes and subthemes are in alphabetical order" do
    visit audits_path

    within("#theme") do
      options = page.all("option")

      expect(options.map(&:text)).to eq [
        "All",
        "All Environment",
        "Air pollution",
        "Forestry",
        "All Travel",
        "Aviation",
      ]

      groups = page.all("optgroup")
      labels = groups.map { |g| g[:label] }

      expect(labels).to eq %w(Environment Travel)
    end
  end

  scenario "filtering by theme" do
    visit audits_path
    select "All Environment", from: "theme"

    click_on "Filter"

    within("table") do
      expect(page).to have_content("Tree felling")
      expect(page).to have_no_content("Forest management")
      expect(page).to have_no_content("DFE")
    end
  end

  scenario "filtering by subtheme" do
    visit audits_path
    select "Aviation", from: "theme"

    click_on "Filter"

    within("table") do
      expect(page).to have_content("Travel insurance")
      expect(page).to have_no_content("Flying to countries abroad")
      expect(page).to have_no_content("DFE")
    end
  end

  scenario "filtering by document type" do
    hmrc.update!(document_type: "organisation")

    visit audits_path
    select "Organisation", from: "document_type"

    click_on "Filter"

    within("table") do
      expect(page).to have_content("HMRC")
      expect(page).to have_no_content("Flying to countries abroad")
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
