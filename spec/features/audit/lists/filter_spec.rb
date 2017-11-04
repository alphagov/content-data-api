RSpec.feature "Filter Content Items to Audit", type: :feature do
  let!(:me) { create(:user) }

  context "I have some unaudited content allocated to me" do
    let!(:famous_five) do
      create(
        :content_item,
        title: "The Famous Five",
        allocated_to: me,
      )
    end

    let!(:secret_seven) do
      create(
        :content_item,
        title: "The Secret Seven",
      )
    end

    let!(:wishing_chair) do
      wishing_chair = create(
        :content_item,
        title: "The Wishing Chair",
        allocated_to: me,
      )

      create(:audit, content_item: wishing_chair, user: me)
      wishing_chair
    end

    scenario "List filters by my unaudited content by default" do
      filter_audit_list = ContentAuditTool.new.filter_audit_list_page
      filter_audit_list.load

      filter_audit_list.filter_form do |form|
        expect(form).to have_select("allocated_to", selected: "Me")
        expect(form.audit_status).to have_checked_field("Not audited")
      end

      expect(filter_audit_list).to have_list(text: "The Famous Five")
      expect(filter_audit_list.list).to have_no_content("The Secret Seven")
      expect(filter_audit_list.list).to have_no_content("The Wishing Chair")
    end
  end

  context "With some organisations and documents set up" do
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

    scenario "filtering audited content" do
      filter_audit_list = ContentAuditTool.new.filter_audit_list_page
      filter_audit_list.load

      filter_audit_list.filter_form do |form|
        form.allocated_to.select "Anyone"
        form.audit_status.choose "Audited"

        form.apply_filters.click
      end

      expect(filter_audit_list.list).to have_content("Tree felling")
      expect(filter_audit_list.list).to have_no_content("Forest management")
      expect(filter_audit_list.filter_form.audit_status).to have_checked_field("audit_status_audited")
    end

    scenario "filtering for content regardless of audit status" do
      filter_audit_list = ContentAuditTool.new.filter_audit_list_page
      filter_audit_list.load

      filter_audit_list.filter_form do |form|
        form.allocated_to.select "Anyone"
        form.audit_status.choose "All"

        form.apply_filters.click
      end

      expect(filter_audit_list).to have_content("Tree felling")
      expect(filter_audit_list).to have_content("Forest management")
      expect(filter_audit_list.filter_form.audit_status).to have_checked_field("audit_status_all")
    end

    context "when showing content regardless of audit status" do
      scenario "filtering by primary organisation" do
        filter_audit_list = ContentAuditTool.new.filter_audit_list_page
        filter_audit_list.load

        filter_audit_list.filter_form do |form|
          form.allocated_to.select "Anyone"
          form.audit_status.choose "All"
          form.apply_filters.click

          expect(form.primary_orgs).to have_checked_field

          form.organisations.select "HMRC"
          # select "HMRC", from: "Organisations"
          form.apply_filters.click
        end

        expect(filter_audit_list.list).to have_content("VAT")
        expect(filter_audit_list.list).to have_no_content("Tree felling")
      end

      scenario "filtering by organisation" do
        filter_audit_list = ContentAuditTool.new.filter_audit_list_page
        filter_audit_list.load

        filter_audit_list.filter_form do |form|
          form.allocated_to.select "Anyone"
          form.audit_status.choose "All"
          form.primary_orgs.uncheck "Primary organisation only"
          form.organisations.select "HMRC"
          form.apply_filters.click
        end

        expect(filter_audit_list.list).to have_content("VAT")
        expect(filter_audit_list.list).to have_content("Travel insurance")
        expect(filter_audit_list.list).to have_no_content("Tree felling")
      end

      scenario "toggling the primary org checkbox by clicking its label" do
        filter_audit_list = ContentAuditTool.new.filter_audit_list_page
        filter_audit_list.load

        filter_audit_list.filter_form do |form|
          expect(form).to have_primary_orgs_label
          expect(form).to have_primary_orgs

          form.primary_orgs_label.click
          expect(form.primary_orgs).not_to have_checked_field

          form.primary_orgs_label.click
          expect(form.primary_orgs).to have_checked_field
        end
      end

      context "filtering by organisation" do
        scenario "organisations are in alphabetical order" do
          filter_audit_list = ContentAuditTool.new.filter_audit_list_page
          filter_audit_list.load

          filter_audit_list.filter_form.wait_until_organisations_visible

          within(filter_audit_list.filter_form.organisations) do
            options = page.all("option")

            expect(options.map(&:text)).to eq ["", "DFE", "HMRC"]
          end
        end

        scenario "using autocomplete", js: true do
          filter_audit_list = ContentAuditTool.new.filter_audit_list_page
          filter_audit_list.load

          expect(filter_audit_list.url).not_to include("organisations%5B%5D=#{hmrc.content_id}")

          filter_audit_list.filter_form do |form|
            form.wait_until_organisations_visible

            expect(form).to have_organisations_input(visible: :visible)
            expect(form).to have_organisations_select(visible: :hidden)

            form.organisations_input.send_keys("HM", :down, :enter)

            expect(form).to have_field("Organisations", with: "HMRC")

            form.apply_filters.click

            expect(form).to have_selector("option[selected][value=\"#{hmrc.content_id}\"]", visible: :hidden)
          end

          expect(filter_audit_list.current_url).to include("organisations%5B%5D=#{hmrc.content_id}")
        end

        scenario "multiple", js: true do
          filter_audit_list = ContentAuditTool.new.filter_audit_list_page
          filter_audit_list.load

          filter_audit_list.filter_form do |form|
            form.wait_until_organisations_visible
            form.add_organisations.click

            page.find_all("#organisations")[1].send_keys("DF", :down, :enter)
            page.find_all("#organisations")[0].send_keys("HM", :down, :enter)

            expect(filter_audit_list).to have_field("Organisations", with: "DFE")
            expect(filter_audit_list).to have_field("Organisations", with: "HMRC")

            form.apply_filters.click

            expect(filter_audit_list.current_url).to include("organisations%5B%5D=#{dfe.content_id}")
            expect(filter_audit_list.current_url).to include("organisations%5B%5D=#{hmrc.content_id}")
          end
        end
      end

      context "filtering by title" do
        scenario "the user enters a text in the search box and retrieves a filtered list" do
          filter_audit_list = ContentAuditTool.new.filter_audit_list_page
          filter_audit_list.load

          create :content_item, title: "some text"
          create :content_item, title: "another text"

          filter_audit_list.filter_form do |form|
            form.allocated_to.select "Anyone"
            form.audit_status.choose "All"

            form.apply_filters.click
          end

          filter_audit_list.filter_form.search.set "some text"
          filter_audit_list.filter_form.apply_filters.click
          expect(filter_audit_list).to have_listing count: 1
        end

        scenario "show the query entered by the user after filtering" do
          filter_audit_list = ContentAuditTool.new.filter_audit_list_page
          filter_audit_list.load

          filter_audit_list.filter_form do |form|
            form.allocated_to.select "Anyone"
            form.audit_status.choose "All"
            form.search.set "a search value"
            form.apply_filters.click
          end

          expect(filter_audit_list).to have_field(:query, with: 'a search value')
        end
      end

      scenario "filtering by content type" do
        filter_audit_list = ContentAuditTool.new.filter_audit_list_page
        filter_audit_list.load

        hmrc.update!(document_type: "guide")

        filter_audit_list.filter_form do |form|
          form.allocated_to.select "Anyone"
          form.audit_status.choose "All"
          form.document_type.select "Guide"

          form.apply_filters.click
        end

        expect(filter_audit_list.list).to have_content("HMRC")
        expect(filter_audit_list.list).to have_no_content("Flying to countries abroad")
      end

      scenario "Reseting page to 1 after filtering" do
        create_list(:content_item, 100)

        filter_audit_list = ContentAuditTool.new.filter_audit_list_page
        filter_audit_list.load

        filter_audit_list.filter_form do |form|
          form.allocated_to.select "Anyone"
          form.audit_status.choose "All"
          form.apply_filters.click
        end

        filter_audit_list.pagination.click_on "2"

        filter_audit_list.filter_form do |form|
          form.audit_status.choose "Not audited"
          form.apply_filters.click
        end

        expect(page).to have_css(".pagination .active", text: "1")
      end
    end
  end
end
