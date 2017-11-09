RSpec.feature "Filter Content Items to Audit", type: :feature do
  scenario "List filters by my unaudited content by default" do
    given_unaudited_content
    when_viewing_content_to_audit
    and_filtering_to_unaudited_content_allocated_to_me_by_default
    then_the_filtered_list_shows_content_allocated_to_me
    and_unaudited_content_not_allocated_to_me_is_not_shown
  end

  scenario "filtering audited content" do
    given_content_belonging_to_departments
    when_viewing_content_to_audit
    and_filtering_to_audited_content_allocated_to_anyone
    then_the_filtered_list_shows_audited_content
    and_the_filtered_list_does_not_show_unaudited_content
  end

  scenario "filtering for content regardless of audit status" do
    given_content_belonging_to_departments
    when_viewing_content_to_audit
    and_filtering_by_all_content_allocated_to_anyone
    then_the_filtered_list_shows_all_content
  end

  scenario "filtering by primary organisation" do
    given_content_belonging_to_departments
    when_viewing_content_to_audit
    and_filtering_to_all_content_for_anyone_belonging_to_a_primary_org
    then_the_filtered_list_shows_primary_org_content
    and_does_not_show_other_department_content
  end

  scenario "filtering by primary and non-primary organisation" do
    given_content_belonging_to_departments
    when_viewing_content_to_audit
    and_filtering_to_non_primary_orgs
    then_the_filtered_list_shows_content_for_org
    and_the_list_does_not_show_content_for_other_orgs
  end

  scenario "toggling the primary org checkbox by clicking its label" do
    given_an_audit_tool_user
    when_viewing_content_to_audit
    the_primary_orgs_checkbox_is_toggled_by_the_label
  end

  scenario "organisation options are in alphabetical order" do
    given_content_belonging_to_departments
    when_viewing_content_to_audit
    the_organisation_filter_options_are_alphabetical
  end

  scenario "using organisation filter option autocomplete", js: true do
    given_content_belonging_to_departments
    when_viewing_content_to_audit
    and_part_of_an_org_name_is_typed_in_the_organisations_filter_field
    then_the_field_is_filled_with_the_suggestion_chosen
    and_when_applying_the_filters
    then_the_option_is_still_set
    and_the_url_contains_the_filter_option_in_query_param
  end

  scenario "multiple", js: true do
    given_content_belonging_to_departments
    when_viewing_content_to_audit
    and_part_of_two_org_names_are_typed_in_the_organisations_filter_field
    then_there_are_fields_filled_with_the_suggestions_chosen
    and_when_applying_the_filters
    then_the_options_are_still_set
    and_the_url_contains_the_filter_options_in_query_params
  end

  scenario "filtering by title" do
    given_content_with_known_titles
    when_viewing_content_to_audit
    and_searching_by_title_within_all_content_assigned_to_anyone
    then_the_filtered_list_shows_the_one_content_matching
    and_does_not_show_other_content_that_do_not_match
  end

  scenario "show the query entered by the user after filtering" do
    given_content_with_known_titles
    when_viewing_content_to_audit
    and_searching_by_title_within_all_content_assigned_to_anyone
    then_the_search_box_still_shows_the_search_query
  end

  scenario "filtering by content type" do
    given_content_belonging_to_departments
    and_one_of_the_content_is_guidance
    when_viewing_content_to_audit
    and_filtering_by_guide_type_from_all_content_allocated_to_anyone
    then_the_filtered_list_shows_content_for_that_type
    and_does_not_show_content_of_other_types
  end

  scenario "Reseting page to 1 after filtering" do
    given_101_content_items
    when_viewing_content_to_audit
    and_filtering_by_all_content_allocated_to_anyone
    and_clicking_to_the_second_page_of_results
    and_changing_the_filters_to_not_audited
    then_the_filtered_list_goes_down_to_one_page
  end

private

  def given_an_audit_tool_user
    create(:user)
  end

  def given_unaudited_content
    me = create(:user)

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

  def when_viewing_content_to_audit
    @audit_content_page = ContentAuditTool.new.audit_content_page
    @audit_content_page.load
  end

  def and_filtering_to_unaudited_content_allocated_to_me_by_default
    @audit_content_page.filter_form do |form|
      expect(form).to have_select("allocated_to", selected: "Me")
      expect(form.audit_status).to have_checked_field("Not audited")
    end
  end

  def then_the_filtered_list_shows_content_allocated_to_me
    @audits_filter_list = ContentAuditTool.new.audits_filter_list

    listing = @audits_filter_list.filter_listings.first
    expect(listing.title).to have_text("The Famous Five")
  end

  def and_unaudited_content_not_allocated_to_me_is_not_shown
    @audits_filter_list.filter_listings.each do |listing|
      expect(listing.title).to have_no_text("The Secret Seven")
      expect(listing.title).to have_no_text("The Wishing Chair")
    end
  end

  def the_primary_orgs_checkbox_is_toggled_by_the_label
    @audit_content_page.filter_form do |form|
      expect(form).to have_primary_orgs_label
      expect(form).to have_primary_orgs

      form.primary_orgs_label.click
      expect(form.primary_orgs).not_to have_checked_field

      form.primary_orgs_label.click
      expect(form.primary_orgs).to have_checked_field
    end
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

  def and_filtering_to_audited_content_allocated_to_anyone
    @audit_content_page.filter_form do |form|
      form.allocated_to.select "Anyone"
      form.audit_status.choose "Audited"

      form.apply_filters.click
    end

    expect(@audit_content_page.filter_form.audit_status).to have_checked_field("audit_status_audited")
  end

  def then_the_filtered_list_shows_audited_content
    @audits_filter_list = ContentAuditTool.new.audits_filter_list
    listing = @audits_filter_list.filter_listings.first

    expect(listing.title).to have_text("Tree felling")
  end

  def and_the_filtered_list_does_not_show_unaudited_content
    @audits_filter_list.filter_listings.each do |listing|
      expect(listing.title).to have_no_text("Forest management")
    end
  end

  def and_filtering_by_all_content_allocated_to_anyone
    @audit_content_page.filter_form do |form|
      form.allocated_to.select "Anyone"
      form.audit_status.choose "All"

      form.apply_filters.click
    end

    expect(@audit_content_page.filter_form.audit_status).to have_checked_field("audit_status_all")
  end

  def then_the_filtered_list_shows_all_content
    expect(@audit_content_page).to have_content("VAT")
    expect(@audit_content_page).to have_content("Tree felling")
    expect(@audit_content_page).to have_content("Forest management")
  end

  def and_filtering_to_all_content_for_anyone_belonging_to_a_primary_org
    @audit_content_page.filter_form do |form|
      form.allocated_to.select "Anyone"
      form.audit_status.choose "All"
      form.primary_orgs.check "Primary organisation only"
      form.organisations.select "HMRC"
      form.apply_filters.click
    end
  end

  def then_the_filtered_list_shows_primary_org_content
    @audits_filter_list = ContentAuditTool.new.audits_filter_list
    listing = @audits_filter_list.filter_listings.first

    expect(listing.title).to have_text("VAT")
  end

  def and_does_not_show_other_department_content
    @audits_filter_list.filter_listings.each do |listing|
      expect(listing.title).to have_no_text("Tree felling")
    end
  end

  def and_filtering_to_non_primary_orgs
    @audit_content_page.filter_form do |form|
      form.allocated_to.select "Anyone"
      form.audit_status.choose "All"
      form.primary_orgs.uncheck "Primary organisation only"
      form.organisations.select "HMRC"
      form.apply_filters.click
    end
  end

  def then_the_filtered_list_shows_content_for_org
    @audits_filter_list = ContentAuditTool.new.audits_filter_list

    expect(@audits_filter_list.filter_listings.size).to eq(2)

    @audits_filter_list.filter_listings.each do |listing|
      expect(listing.title.text).to eq("VAT").or eq("Travel insurance")
    end
  end

  def and_the_list_does_not_show_content_for_other_orgs
    @audits_filter_list.filter_listings.each do |listing|
      expect(listing.title).to have_no_content("Tree felling")
    end
  end

  def the_organisation_filter_options_are_alphabetical
    @audit_content_page.filter_form do |form|
      within(form.organisations) do
        options = page.all("option")

        expect(options.map(&:text)).to eq ["", "DFE", "HMRC"]
      end
    end
  end

  def and_part_of_an_org_name_is_typed_in_the_organisations_filter_field
    expect(@audit_content_page.url).not_to include("organisations%5B%5D=#{@hmrc.content_id}")

    @audit_content_page.filter_form do |form|
      form.wait_until_organisations_visible

      expect(form).to have_organisations_input(visible: :visible)
      expect(form).to have_organisations_select(visible: :hidden)

      form.organisations_input.send_keys("HM", :down, :enter)
    end
  end

  def then_the_field_is_filled_with_the_suggestion_chosen
    @audit_content_page.filter_form do |form|
      expect(form).to have_field("Organisations", with: "HMRC")
    end
  end

  def and_when_applying_the_filters
    @audit_content_page.filter_form do |form|
      form.apply_filters.click
    end
  end

  def then_the_option_is_still_set
    @audit_content_page.filter_form do |form|
      expect(form).to have_selector("option[selected][value=\"#{@hmrc.content_id}\"]", visible: :hidden)
    end
  end

  def and_the_url_contains_the_filter_option_in_query_param
    expect(@audit_content_page.current_url).to include("organisations%5B%5D=#{@hmrc.content_id}")
  end

  def and_part_of_two_org_names_are_typed_in_the_organisations_filter_field
    @audit_content_page.filter_form do |form|
      form.wait_until_organisations_visible
      form.add_organisations.click

      page.find_all("#organisations")[1].send_keys("DF", :down, :enter)
      page.find_all("#organisations")[0].send_keys("HM", :down, :enter)
    end
  end

  def then_there_are_fields_filled_with_the_suggestions_chosen
    expect(@audit_content_page).to have_field("Organisations", with: "DFE")
    expect(@audit_content_page).to have_field("Organisations", with: "HMRC")
  end

  def then_the_options_are_still_set
    @audit_content_page.filter_form do |form|
      expect(form).to have_selector("option[selected][value=\"#{@hmrc.content_id}\"]", visible: :hidden)
      expect(form).to have_selector("option[selected][value=\"#{@dfe.content_id}\"]", visible: :hidden)
    end
  end

  def and_the_url_contains_the_filter_options_in_query_params
    expect(@audit_content_page.current_url).to include("organisations%5B%5D=#{@dfe.content_id}")
    expect(@audit_content_page.current_url).to include("organisations%5B%5D=#{@hmrc.content_id}")
  end

  def given_content_with_known_titles
    create :user
    create :content_item, title: "some text"
    create :content_item, title: "another text"
  end

  def and_searching_by_title_within_all_content_assigned_to_anyone
    @audit_content_page.filter_form do |form|
      form.allocated_to.select "Anyone"
      form.audit_status.choose "All"
      form.search.set "some text"
      form.apply_filters.click
    end
  end

  def then_the_filtered_list_shows_the_one_content_matching
    @audits_filter_list = ContentAuditTool.new.audits_filter_list

    expect(@audits_filter_list).to have_filter_listings
    expect(@audits_filter_list.filter_listings.size).to eq(1)
    listing = @audits_filter_list.filter_listings.first
    expect(listing.title).to have_text("some text")
  end

  def and_does_not_show_other_content_that_do_not_match
    @audits_filter_list.filter_listings.each do |listing|
      expect(listing.title).to have_no_text("another text")
    end
  end

  def then_the_search_box_still_shows_the_search_query
    expect(@audit_content_page).to have_field(:query, with: 'some text')
  end

  def and_one_of_the_content_is_guidance
    @hmrc.update!(document_type: "guide")
  end

  def and_filtering_by_guide_type_from_all_content_allocated_to_anyone
    @audit_content_page.filter_form do |form|
      form.allocated_to.select "Anyone"
      form.audit_status.choose "All"
      form.document_type.select "Guide"

      form.apply_filters.click
    end
  end

  def then_the_filtered_list_shows_content_for_that_type
    @audits_filter_list = ContentAuditTool.new.audits_filter_list
    @audits_filter_list.wait_for_filter_listings

    expect(@audits_filter_list.filter_listings.size).to eq(1)

    listing = @audits_filter_list.filter_listings.first
    expect(listing.title.text).to eq("HMRC")
  end

  def and_does_not_show_content_of_other_types
    @audits_filter_list = ContentAuditTool.new.audits_filter_list
    @audits_filter_list.filter_listings.each do |listing|
      expect(listing.title.text).not_to eq("Flying to countries abroad")
    end
  end

  def given_101_content_items
    create :user
    create_list(:content_item, 101)
  end

  def and_clicking_to_the_second_page_of_results
    @audit_content_page.pagination.click_on "2"
  end

  def and_changing_the_filters_to_not_audited
    @audit_content_page.filter_form do |form|
      form.audit_status.choose "Not audited"
      form.apply_filters.click
    end
  end

  def then_the_filtered_list_goes_down_to_one_page
    expect(page).to have_css(".pagination .active", text: "1")
  end
end
