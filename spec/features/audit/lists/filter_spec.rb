RSpec.feature "Filter Content Items to Audit", type: :feature do
  scenario "List filters by my unaudited content by default" do
    given_unaudited_content
    when_viewing_content_to_audit
    and_filtering_to_unaudited_content_by_default
    then_the_filtered_list_shows_content_allocated_to_me
    and_unaudited_content_not_allocated_to_me_is_not_shown
  end

  scenario "filtering audited content" do
    given_content_belonging_to_departments_and_allocated_to_me
    when_viewing_content_to_audit
    and_filtering_to_audited_content
    then_the_filtered_list_shows_audited_content
    and_the_filtered_list_does_not_show_unaudited_content
  end

  scenario "filtering for content regardless of audit status" do
    given_content_belonging_to_departments_and_allocated_to_me
    when_viewing_content_to_audit
    and_filtering_by_all_content
    then_the_filtered_list_shows_all_content
  end

  scenario "filtering by primary organisation" do
    given_content_belonging_to_departments_and_allocated_to_me
    when_viewing_content_to_audit
    and_filtering_to_all_content_belonging_to_a_primary_org
    then_the_filtered_list_shows_primary_org_content
    and_does_not_show_other_department_content
  end

  scenario "filtering by primary and non-primary organisation" do
    given_content_belonging_to_departments_and_allocated_to_me
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
    given_content_belonging_to_departments_and_allocated_to_me
    when_viewing_content_to_audit
    the_organisation_filter_options_are_alphabetical
  end

  scenario "using organisation filter option autocomplete", js: true do
    given_content_belonging_to_departments_and_allocated_to_me
    when_viewing_content_to_audit
    and_part_of_an_organisation_name_is_typed
    then_the_organisation_filter_is_filled_with_the_suggestion_chosen
    and_when_applying_the_filters
    then_the_organisation_filter_is_still_set
    and_the_url_contains_the_organisation_filter_option_in_query_params
  end

  scenario "multiple organisations" do
    given_content_belonging_to_departments_and_allocated_to_me
    when_viewing_content_to_audit
    and_selecting_two_organisations
    and_when_applying_the_filters
    then_the_organisation_filters_are_still_set
    and_the_url_contains_the_organisation_filters_in_the_query_params
  end

  scenario "using topic filter option autocomplete", js: true do
    given_content_with_known_topics
    when_viewing_content_to_audit
    and_part_of_an_topic_name_is_typed
    then_the_topic_filter_is_filled_with_the_suggestion_chosen
    and_when_applying_the_filters
    then_the_topic_filter_is_still_set
    and_the_url_contains_the_topic_filter_option_in_query_params
  end

  scenario "multiple topics" do
    given_content_with_known_topics
    when_viewing_content_to_audit
    and_selecting_two_topics
    and_when_applying_the_filters
    then_the_topic_filters_are_still_set
    and_the_url_contains_the_topic_filters_in_the_query_params
  end

  scenario "filtering by title" do
    given_content_with_known_titles
    when_viewing_content_to_audit
    and_searching_by_title_within_all_content
    then_the_filtered_list_shows_the_one_content_matching
    and_does_not_show_other_content_that_do_not_match
  end

  scenario "show the query entered by the user after filtering" do
    given_content_with_known_titles
    when_viewing_content_to_audit
    and_searching_by_title_within_all_content
    then_the_search_box_still_shows_the_search_query
  end

  scenario "filtering by content type" do
    given_content_belonging_to_departments_and_allocated_to_me
    when_viewing_content_to_audit
    and_filtering_by_guide_type_from_all_content
    then_the_filtered_list_shows_content_for_that_type
    and_does_not_show_content_of_other_types
  end

  scenario "Reseting page to 1 after filtering" do
    given_101_content_items
    when_viewing_content_to_audit
    and_filtering_by_all_content
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

  def and_filtering_to_unaudited_content_by_default
    @audit_content_page.filter_form do |form|
      expect(form.audit_status).to have_checked_field("Not audited")
    end
  end

  def then_the_filtered_list_shows_content_allocated_to_me
    @audits_filter_list = ContentAuditTool.new.audits_filter_list
    listing = @audits_filter_list.listings.first

    expect(listing.title).to have_text("The Famous Five")
  end

  def and_unaudited_content_not_allocated_to_me_is_not_shown
    @audits_filter_list.listings.each do |listing|
      expect(listing).to have_no_title(text: "The Secret Seven")
      expect(listing).to have_no_title(text: "The Wishing Chair")
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

  def given_content_belonging_to_departments_and_allocated_to_me
    me = create(:user)

    # Organisations:
    @hmrc = create(:organisation, title: "HMRC")
    @defra = create(:organisation, title: "DEFRA")

    # Policies:
    flying = create(:content_item, title: "Flying abroad")

    create(
      :content_item,
      title: "Travel insurance",
      organisations: @hmrc,
      policies: flying,
      allocated_to: me,
    )

    # Content:
    management =
      create(
        :content_item,
        title: "Forest management",
        document_type: "answer",
        allocated_to: me,
      )

    felling =
      create(
        :content_item,
        title: "Tree felling",
        primary_publishing_organisation: @defra,
        policies: management,
        document_type: "guide",
        allocated_to: me,
      )

    create(
      :content_item,
      title: "VAT",
      primary_publishing_organisation: @hmrc,
      organisations: @hmrc,
      allocated_to: me,
    )

    # Audit:
    create(:audit, content_item: felling)
  end

  def and_filtering_to_audited_content
    @audit_content_page.filter_form do |form|
      form.audit_status.choose "Audited"
      form.apply_filters.click
    end

    expect(@audit_content_page.filter_form.audit_status).to have_checked_field("audit_status_audited")
  end

  def then_the_filtered_list_shows_audited_content
    @audits_filter_list = ContentAuditTool.new.audits_filter_list

    expect(@audits_filter_list.list).to have_text("Tree felling")
  end

  def and_the_filtered_list_does_not_show_unaudited_content
    @audits_filter_list.listings.each do |listing|
      expect(listing).to have_no_title(text: "Forest management")
      expect(listing).to have_no_title(text: "Travel insurance")
      expect(listing).to have_no_title(text: "VAT")
    end
  end

  def and_filtering_by_all_content
    @audit_content_page.filter_form do |form|
      form.audit_status.choose "All"
      form.apply_filters.click
    end

    expect(@audit_content_page.filter_form.audit_status).to have_checked_field("audit_status_all")
  end

  def then_the_filtered_list_shows_all_content
    @audits_filter_list = ContentAuditTool.new.audits_filter_list

    expect(@audits_filter_list.list).to have_content("VAT")
    expect(@audits_filter_list.list).to have_content("Tree felling")
    expect(@audits_filter_list.list).to have_content("Forest management")
    expect(@audits_filter_list.list).to have_content("Travel insurance")
  end

  def and_filtering_to_all_content_belonging_to_a_primary_org
    @audit_content_page.filter_form do |form|
      form.audit_status.choose "All"
      form.primary_orgs.check "Primary organisation only"
      form.organisations.select "HMRC"
      form.apply_filters.click
    end
  end

  def then_the_filtered_list_shows_primary_org_content
    @audits_filter_list = ContentAuditTool.new.audits_filter_list
    listing = @audits_filter_list.listings.first

    expect(listing.title).to have_text("VAT")
  end

  def and_does_not_show_other_department_content
    @audits_filter_list.listings.each do |listing|
      expect(listing).to have_no_title(text: "Tree felling")
      expect(listing).to have_no_title(text: "Forest management")
      expect(listing).to have_no_title(text: "Travel insurance")
    end
  end

  def and_filtering_to_non_primary_orgs
    @audit_content_page.filter_form do |form|
      form.audit_status.choose "All"
      form.primary_orgs.uncheck "Primary organisation only"
      form.organisations.select "HMRC"
      form.apply_filters.click
    end
  end

  def then_the_filtered_list_shows_content_for_org
    @audits_filter_list = ContentAuditTool.new.audits_filter_list

    expect(@audits_filter_list).to have_listings(count: 2)

    @audits_filter_list.listings.each do |listing|
      expect(listing.title.text).to eq("VAT").or eq("Travel insurance")
    end
  end

  def and_the_list_does_not_show_content_for_other_orgs
    @audits_filter_list.listings.each do |listing|
      expect(listing).to have_no_title(text: "Tree felling")
      expect(listing).to have_no_title(text: "Forest management")
    end
  end

  def the_organisation_filter_options_are_alphabetical
    @audit_content_page.filter_form do |form|
      within(form.organisations) do
        options = page.all("option")

        expect(options.map(&:text)).to eq ["", "DEFRA", "HMRC"]
      end
    end
  end

  def and_part_of_an_organisation_name_is_typed
    expect(@audit_content_page.url).not_to include("organisations%5B%5D=#{@hmrc.content_id}")

    @audit_content_page.filter_form do |form|
      form.wait_until_organisations_visible

      expect(form).to have_organisations_input(visible: :visible)
      expect(form).to have_organisations_select(visible: :hidden)

      form.organisations_input.send_keys("HM", :down, :enter)
    end
  end

  def and_part_of_an_topic_name_is_typed
    expect(@audit_content_page.url).not_to include("topics%5B%5D=#{@paye.content_id}")

    @audit_content_page.filter_form do |form|
      form.wait_until_topics_visible

      expect(form).to have_topics_input(visible: :visible)
      expect(form).to have_topics_select(visible: :hidden)

      form.topics_input.send_keys('PAY', :down, :enter)
    end
  end

  def then_the_organisation_filter_is_filled_with_the_suggestion_chosen
    @audit_content_page.filter_form do |form|
      expect(form).to have_field("Organisations", with: "HMRC")
    end
  end

  def then_the_topic_filter_is_filled_with_the_suggestion_chosen
    @audit_content_page.filter_form do |form|
      expect(form).to have_field('Topics', with: 'Business tax: PAYE')
    end
  end

  def and_when_applying_the_filters
    @audit_content_page.filter_form do |form|
      form.apply_filters.click
    end
  end

  def then_the_organisation_filter_is_still_set
    @audit_content_page.filter_form do |form|
      expect(form).to have_selector("option[selected][value=\"#{@hmrc.content_id}\"]", visible: :hidden)
    end
  end

  def then_the_topic_filter_is_still_set
    @audit_content_page.filter_form do |form|
      expect(form).to have_selector("option[selected][value=\"#{@paye.content_id}\"]", visible: :hidden)
    end
  end

  def and_the_url_contains_the_organisation_filter_option_in_query_params
    expect(@audit_content_page.current_url).to include("organisations%5B%5D=#{@hmrc.content_id}")
  end

  def and_the_url_contains_the_topic_filter_option_in_query_params
    expect(@audit_content_page.current_url).to include("topics%5B%5D=#{@paye.content_id}")
  end

  def and_selecting_two_organisations
    @audit_content_page.filter_form do |form|
      form.organisations.select "DEFRA"
      form.organisations.select "HMRC"
    end
  end

  def and_selecting_two_topics
    @audit_content_page.filter_form do |form|
      form.topics.select "PAYE"
      form.topics.select "VAT"
    end
  end

  def then_the_organisation_filters_are_still_set
    @audit_content_page.filter_form do |form|
      expect(form).to have_selector("option[selected][value=\"#{@hmrc.content_id}\"]")
      expect(form).to have_selector("option[selected][value=\"#{@defra.content_id}\"]")
    end
  end

  def then_the_topic_filters_are_still_set
    @audit_content_page.filter_form do |form|
      expect(form).to have_selector("option[selected][value=\"#{@paye.content_id}\"]")
      expect(form).to have_selector("option[selected][value=\"#{@vat.content_id}\"]")
    end
  end

  def and_the_url_contains_the_organisation_filters_in_the_query_params
    expect(@audit_content_page.current_url).to include("organisations[]=#{@defra.content_id}")
    expect(@audit_content_page.current_url).to include("organisations[]=#{@hmrc.content_id}")
  end

  def and_the_url_contains_the_topic_filters_in_the_query_params
    expect(@audit_content_page.current_url).to include("topics[]=#{@paye.content_id}")
    expect(@audit_content_page.current_url).to include("topics[]=#{@vat.content_id}")
  end

  def given_content_with_known_titles
    me = create(:user)
    create(:content_item, title: "some text", allocated_to: me)
    create(:content_item, title: "another text", allocated_to: me)
  end

  def given_content_with_known_topics
    create :user

    business_tax = create(:topic, title: 'Business tax')

    @paye = create(:topic, title: 'PAYE', parent: business_tax)
    @vat = create(:topic, title: 'VAT', parent: business_tax)

    create(
      :content_item,
      title: 'Tell HMRC about a new employee',
      topics: @paye,
    )

    create(
      :content_item,
      title: 'VAT registration',
      topics: @vat,
    )
  end

  def and_searching_by_title_within_all_content
    @audit_content_page.filter_form do |form|
      form.audit_status.choose "All"
      form.search.set "some text"
      form.apply_filters.click
    end
  end

  def then_the_filtered_list_shows_the_one_content_matching
    @audits_filter_list = ContentAuditTool.new.audits_filter_list

    expect(@audits_filter_list).to have_listings(count: 1)

    listing = @audits_filter_list.listings.first

    expect(listing.title).to have_text("some text")
  end

  def and_does_not_show_other_content_that_do_not_match
    @audits_filter_list.listings.each do |listing|
      expect(listing).to have_no_title(text: "another text")
    end
  end

  def then_the_search_box_still_shows_the_search_query
    expect(@audit_content_page).to have_field(:query, with: 'some text')
  end

  def and_filtering_by_guide_type_from_all_content
    @audit_content_page.filter_form do |form|
      form.audit_status.choose "All"
      form.document_type.select "Guide"

      form.apply_filters.click
    end
  end

  def then_the_filtered_list_shows_content_for_that_type
    using_wait_time 5 do
      @audits_filter_list = ContentAuditTool.new.audits_filter_list
    end

    expect(@audits_filter_list.wait_for_listings(count: 1))
    expect(@audits_filter_list.list).to have_text("Tree felling")
  end

  def and_does_not_show_content_of_other_types
    expect(@audits_filter_list.list).to have_no_text("Forest management")
  end

  def given_101_content_items
    me = create(:user)
    create_list(:content_item, 101, allocated_to: me)
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
