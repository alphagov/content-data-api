RSpec.feature "Filter Content Items to Audit", type: :feature do
  around(:each) do |example|
    Feature.run_with_activated(:filtering_themes, :auditing_allocation) { example.run }
  end

  # Organisations:
  let!(:hmrc) { create(:organisation, title: "HMRC") }
  let!(:dfe) { create(:organisation, title: "DFE") }

  # Policies:
  let!(:flying) { create(:content_item, title: "Flying abroad") }

  let!(:insurance) do
    create(
      :content_item,
      title: "Travel insurance",
      organisations: hmrc,
      policies: flying,
    )
  end

  # Content:
  let!(:felling) do
    create(
      :content_item,
      title: "Tree felling",
      primary_publishing_organisation: dfe,
      policies: management,
    )
  end

  let!(:management) do
    create(
      :content_item,
      title: "Forest management",
    )
  end

  let!(:vat) do
    create(
      :content_item,
      title: "VAT",
      primary_publishing_organisation: hmrc,
      organisations: hmrc,
    )
  end

  # Audit:
  let!(:audit) { create(:audit, content_item: felling) }

  # Themes:
  let!(:travel) { create(:theme, name: "Travel") }
  let!(:environment) { create(:theme, name: "Environment") }

  # Subthemes:
  let!(:aviation) { create(:subtheme, theme: travel, name: "Aviation") }
  let!(:forestry) { create(:subtheme, theme: environment, name: "Forestry") }
  let!(:pollution) { create(:subtheme, theme: environment, name: "Air pollution") }

  before do
    # Rules:
    create(:inventory_rule, subtheme: aviation, link_type: "policies", target_content_id: flying.content_id)
    create(:inventory_rule, subtheme: forestry, link_type: "policies", target_content_id: management.content_id)
  end

  scenario "List not audited by default" do
    visit audits_path
    expect(page).to have_selector(".nav")

    expect(page).to have_no_content("Tree felling")
    expect(page).to have_content("Forest management")
    expect(page).to have_checked_field("audit_status_non_audited")
  end

  scenario "filtering audited content" do
    visit audits_path
    select "Anyone", from: "allocated_to"

    choose "Audited"
    click_on "Apply filters"

    expect(page).to have_content("Tree felling")
    expect(page).to have_no_content("Forest management")
    expect(page).to have_checked_field("audit_status_audited")
  end

  scenario "filtering for content regardless of audit status" do
    visit audits_path
    select "Anyone", from: "allocated_to"

    choose "All"
    click_on "Apply filters"

    expect(page).to have_content("Tree felling")
    expect(page).to have_content("Forest management")
    expect(page).to have_checked_field("audit_status_all")
  end

  context "when showing content regardless of audit status" do
    before(:each) do
      visit audits_path
      select "Anyone", from: "allocated_to"

      choose "All"
      click_on "Apply filters"
    end

    scenario "filtering by primary organisation" do
      expect(page.find("#primary")).to be_checked

      select "HMRC", from: "organisations"

      click_on "Apply filters"

      expect(page).to have_content("VAT")
      expect(page).to have_no_content("Tree felling")
    end

    scenario "filtering by organisation" do
      uncheck "primary"

      select "HMRC", from: "organisations"

      click_on "Apply filters"

      expect(page).to have_content("VAT")
      expect(page).to have_content("Travel insurance")
      expect(page).to have_no_content("Tree felling")
    end

    scenario "toggling the primary org checkbox by clicking its label" do
      page.find("label[for='primary']").click
      expect(page.find("#primary")).not_to be_checked

      page.find("label[for='primary']").click
      expect(page.find("#primary")).to be_checked
    end

    context "filtering by organisation" do
      scenario "organisations are in alphabetical order" do
        within("#organisations") do
          options = page.all("option")

          expect(options.map(&:text)).to eq ["", "DFE", "HMRC"]
        end
      end

      scenario "using autocomplete", js: true do
        expect(page.current_url).not_to include("organisations=#{hmrc.content_id}")

        organisations_autocomplete = page.find("#organisations")
        organisations_autocomplete.send_keys("HM", :down, :enter)

        click_on "Apply filters"

        expect(page.current_url).to include("organisations=#{hmrc.content_id}")
      end
    end

    context "filtering by title" do
      scenario "the user enters a text in the search box and retrieves a filtered list" do
        create :content_item, title: "some text"
        create :content_item, title: "another text"

        fill_in "query", with: "some text"
        click_on "Apply filters"

        expect(page).to have_selector("main tbody tr", count: 1)
      end

      scenario "show the query entered by the user after filtering" do
        fill_in 'query', with: 'a search value'
        click_on "Apply filters"

        expect(page).to have_field(:query, with: 'a search value')
      end
    end

    scenario "themes and subthemes are in alphabetical order" do
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
      select "All Environment", from: "theme"

      click_on "Apply filters"

      within("table") do
        expect(page).to have_content("Tree felling")
        expect(page).to have_no_content("Forest management")
        expect(page).to have_no_content("DFE")
      end
    end

    scenario "filtering by subtheme" do
      select "Aviation", from: "theme"

      click_on "Apply filters"

      within("table") do
        expect(page).to have_content("Travel insurance")
        expect(page).to have_no_content("Flying to countries abroad")
        expect(page).to have_no_content("DFE")
      end
    end

    scenario "filtering by document type" do
      hmrc.update!(document_type: "guide")

      select "Guide", from: "document_type"

      click_on "Apply filters"

      within("table") do
        expect(page).to have_content("HMRC")
        expect(page).to have_no_content("Flying to countries abroad")
      end
    end

    scenario "Reseting page to 1 after filtering" do
      create_list(:content_item, 25)

      visit audits_path
      select "Anyone", from: "allocated_to"

      choose "All"
      click_on "Apply filters"

      within(".pagination") { click_on "2" }

      choose "Not audited"
      click_on "Apply filters"

      expect(page).to have_css(".pagination .active", text: "1")
    end
  end
end
