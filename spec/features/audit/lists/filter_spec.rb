RSpec.feature "Filter Content Items to Audit", type: :feature do
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

      select "HMRC", from: "Organisations"

      click_on "Apply filters"

      expect(page).to have_content("VAT")
      expect(page).to have_no_content("Tree felling")
    end

    scenario "filtering by organisation" do
      uncheck "primary"

      select "HMRC", from: "Organisations"

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
        expect(page.current_url).not_to include("organisations%5B%5D=#{hmrc.content_id}")

        click_on "More options"
        expect(page).to have_selector("#organisations", visible: true)

        organisations_autocomplete = page.find("#organisations")
        organisations_autocomplete.send_keys("HM", :down, :enter)

        click_on "Apply filters"

        expect(page.current_url).to include("organisations%5B%5D=#{hmrc.content_id}")
      end

      scenario "multiple", js: true do
        expect(page.current_url).not_to include("organisations%5B%5D=#{hmrc.content_id}")

        click_on "More options"
        expect(page).to have_selector("#add-organisation", visible: true)

        page.find("#add-organisation").click

        page.find_all("#organisations")[1].send_keys("DF", :down, :enter)
        page.find_all("#organisations")[0].send_keys("HM", :down, :enter)

        click_on "Apply filters"

        expect(page.current_url).to include("organisations%5B%5D=#{dfe.content_id}")
        expect(page.current_url).to include("organisations%5B%5D=#{hmrc.content_id}")
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
