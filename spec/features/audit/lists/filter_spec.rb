RSpec.feature "Filter Content Items to Audit", type: :feature do
  let!(:me) { create(:user) }

  scenario "List filters by my unaudited content by default" do
    given_i_have_unaudited_content
    when_i_go_to_filter_content_to_audit
    and_we_filter_to_unaudited_content_allocated_to_me_by_default
    then_the_filtered_list_shows_content_allocated_to_me
    and_we_do_not_show_unaudited_content_not_allocated_to_me
  end

  scenario "filtering audited content" do
    given_content_belonging_to_departments
    when_i_go_to_filter_content_to_audit
    and_i_filter_to_audited_content_allocated_to_anyone
    then_the_filter_list_shows_audited_item
    and_the_list_does_not_show_unaudited_content
  end

  scenario "filtering for content regardless of audit status" do
    given_content_belonging_to_departments
    when_i_go_to_filter_content_to_audit
    and_filter_by_all_content_allocated_to_anyone
    then_the_list_shows_all_content
  end

  scenario "filtering by primary organisation" do
    given_content_belonging_to_departments
    when_i_go_to_filter_content_to_audit
    and_i_filter_to_all_content_for_anyone_belonging_to_a_primary_org
    then_the_list_shows_primary_org_content
    and_does_not_show_other_department_content
  end

  context "With some organisations and documents set up" do
    context "when showing content regardless of audit status" do
      scenario "filtering by organisation" do
        given_content_belonging_to_departments
        when_i_go_to_filter_content_to_audit

        @filter_audit_list.filter_form do |form|
          form.allocated_to.select "Anyone"
          form.audit_status.choose "All"
          form.primary_orgs.uncheck "Primary organisation only"
          form.organisations.select "HMRC"
          form.apply_filters.click
        end

        expect(@filter_audit_list.list).to have_content("VAT")
        expect(@filter_audit_list.list).to have_content("Travel insurance")
        expect(@filter_audit_list.list).to have_no_content("Tree felling")
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
          given_content_belonging_to_departments
          when_i_go_to_filter_content_to_audit

          @filter_audit_list.filter_form.wait_until_organisations_visible

          within(@filter_audit_list.filter_form.organisations) do
            options = page.all("option")

            expect(options.map(&:text)).to eq ["", "DFE", "HMRC"]
          end
        end

        scenario "using autocomplete", js: true do
          given_content_belonging_to_departments
          when_i_go_to_filter_content_to_audit

          expect(@filter_audit_list.url).not_to include("organisations%5B%5D=#{@hmrc.content_id}")

          @filter_audit_list.filter_form do |form|
            form.wait_until_organisations_visible

            expect(form).to have_organisations_input(visible: :visible)
            expect(form).to have_organisations_select(visible: :hidden)

            form.organisations_input.send_keys("HM", :down, :enter)

            expect(form).to have_field("Organisations", with: "HMRC")

            form.apply_filters.click

            expect(form).to have_selector("option[selected][value=\"#{@hmrc.content_id}\"]", visible: :hidden)
          end

          expect(@filter_audit_list.current_url).to include("organisations%5B%5D=#{@hmrc.content_id}")
        end

        scenario "multiple", js: true do
          given_content_belonging_to_departments
          when_i_go_to_filter_content_to_audit

          @filter_audit_list.filter_form do |form|
            form.wait_until_organisations_visible
            form.add_organisations.click

            page.find_all("#organisations")[1].send_keys("DF", :down, :enter)
            page.find_all("#organisations")[0].send_keys("HM", :down, :enter)

            expect(@filter_audit_list).to have_field("Organisations", with: "DFE")
            expect(@filter_audit_list).to have_field("Organisations", with: "HMRC")

            form.apply_filters.click

            expect(@filter_audit_list.current_url).to include("organisations%5B%5D=#{@dfe.content_id}")
            expect(@filter_audit_list.current_url).to include("organisations%5B%5D=#{@hmrc.content_id}")
          end
        end
      end

      context "filtering by title" do
        scenario "the user enters a text in the search box and retrieves a filtered list" do
          given_content_belonging_to_departments
          when_i_go_to_filter_content_to_audit

          create :content_item, title: "some text"
          create :content_item, title: "another text"

          @filter_audit_list.filter_form do |form|
            form.allocated_to.select "Anyone"
            form.audit_status.choose "All"

            form.apply_filters.click
          end

          @filter_audit_list.filter_form.search.set "some text"
          @filter_audit_list.filter_form.apply_filters.click
          expect(@filter_audit_list).to have_listing count: 1
        end

        scenario "show the query entered by the user after filtering" do
          given_content_belonging_to_departments
          when_i_go_to_filter_content_to_audit

          @filter_audit_list.filter_form do |form|
            form.allocated_to.select "Anyone"
            form.audit_status.choose "All"
            form.search.set "a search value"
            form.apply_filters.click
          end

          expect(@filter_audit_list).to have_field(:query, with: 'a search value')
        end
      end

      scenario "filtering by content type" do
        given_content_belonging_to_departments
        when_i_go_to_filter_content_to_audit

        @hmrc.update!(document_type: "guide")

        @filter_audit_list.filter_form do |form|
          form.allocated_to.select "Anyone"
          form.audit_status.choose "All"
          form.document_type.select "Guide"

          form.apply_filters.click
        end

        expect(@filter_audit_list.list).to have_content("HMRC")
        expect(@filter_audit_list.list).to have_no_content("Flying to countries abroad")
      end

      scenario "Reseting page to 1 after filtering" do
        create_list(:content_item, 100)

        given_content_belonging_to_departments
        when_i_go_to_filter_content_to_audit

        @filter_audit_list.filter_form do |form|
          form.allocated_to.select "Anyone"
          form.audit_status.choose "All"
          form.apply_filters.click
        end

        @filter_audit_list.pagination.click_on "2"

        @filter_audit_list.filter_form do |form|
          form.audit_status.choose "Not audited"
          form.apply_filters.click
        end

        expect(page).to have_css(".pagination .active", text: "1")
      end
    end
  end

private

  def given_i_have_unaudited_content
    create(
      :content_item,
      title: "The Famous Five",
      allocated_to: me,
    )

    create(
      :content_item,
      title: "The Secret Seven",
    )

    wishing_chair = create(
      :content_item,
      title: "The Wishing Chair",
      allocated_to: me,
    )

    create(:audit, content_item: wishing_chair, user: me)
  end

  def when_i_go_to_filter_content_to_audit
    @filter_audit_list = ContentAuditTool.new.filter_audit_list_page
    @filter_audit_list.load
  end

  def and_we_filter_to_unaudited_content_allocated_to_me_by_default
    @filter_audit_list.filter_form do |form|
      expect(form).to have_select("allocated_to", selected: "Me")
      expect(form.audit_status).to have_checked_field("Not audited")
    end
  end

  def then_the_filtered_list_shows_content_allocated_to_me
    expect(@filter_audit_list).to have_list(text: "The Famous Five")
  end

  def and_we_do_not_show_unaudited_content_not_allocated_to_me
    expect(@filter_audit_list.list).to have_no_content("The Secret Seven")
    expect(@filter_audit_list.list).to have_no_content("The Wishing Chair")
  end

  def given_content_belonging_to_departments
    # Organisations:
    @hmrc = create(:organisation, title: "HMRC")
    @dfe = create(:organisation, title: "DFE")

    # Policies:
    flying = create(:content_item, title: "Flying abroad")

    create(
      :content_item,
      title: "Travel insurance",
      organisations: @hmrc,
      policies: flying,
    )

    # Content:
    management =
      create(
        :content_item,
        title: "Forest management",
      )

    felling =
      create(
        :content_item,
        title: "Tree felling",
        primary_publishing_organisation: @dfe,
        policies: management,
      )

    create(
      :content_item,
      title: "VAT",
      primary_publishing_organisation: @hmrc,
      organisations: @hmrc,
    )

    # Audit:
    create(:audit, content_item: felling)
  end

  def and_i_filter_to_audited_content_allocated_to_anyone
    @filter_audit_list.filter_form do |form|
      form.allocated_to.select "Anyone"
      form.audit_status.choose "Audited"

      form.apply_filters.click
    end

    expect(@filter_audit_list.filter_form.audit_status).to have_checked_field("audit_status_audited")
  end

  def then_the_filter_list_shows_audited_item
    expect(@filter_audit_list.list).to have_content("Tree felling")
  end

  def and_the_list_does_not_show_unaudited_content
    expect(@filter_audit_list.list).to have_no_content("Forest management")
  end

  def and_filter_by_all_content_allocated_to_anyone
    @filter_audit_list.filter_form do |form|
      form.allocated_to.select "Anyone"
      form.audit_status.choose "All"

      form.apply_filters.click
    end

    expect(@filter_audit_list.filter_form.audit_status).to have_checked_field("audit_status_all")
  end

  def then_the_list_shows_all_content
    expect(@filter_audit_list).to have_content("VAT")
    expect(@filter_audit_list).to have_content("Tree felling")
    expect(@filter_audit_list).to have_content("Forest management")
  end

  def and_i_filter_to_all_content_for_anyone_belonging_to_a_primary_org
    @filter_audit_list.filter_form do |form|
      form.allocated_to.select "Anyone"
      form.audit_status.choose "All"
      form.primary_orgs.check "Primary organisation only"
      form.organisations.select "HMRC"
      form.apply_filters.click
    end
  end

  def then_the_list_shows_primary_org_content
    expect(@filter_audit_list.list).to have_content("VAT")
  end

  def and_does_not_show_other_department_content
    expect(@filter_audit_list.list).to have_no_content("Tree felling")
  end
end
