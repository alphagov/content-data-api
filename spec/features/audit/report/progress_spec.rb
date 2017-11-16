RSpec.feature "Reporting on audit progress" do
  scenario "Displaying the number of items included in the audit" do
    given_i_am_an_auditor_belonging_to_an_organisation_with_three_content_items
    and_one_content_item_needs_improvement_and_one_does_not
    when_i_visit_the_report_page
    then_i_see_the_report_includes_all_three_content_items
    when_i_select_a_document_type_that_does_not_apply_to_any_content_item
    then_i_see_the_report_includes_no_content_items
    when_i_select_a_document_type_that_applies_to_all_three_content_items
    then_i_see_the_report_includes_all_three_content_items
  end

  scenario "Displaying the number of items audited/not audited" do
    given_i_am_an_auditor_belonging_to_an_organisation_with_three_content_items
    and_two_items_have_been_audited
    when_i_visit_the_report_page
    then_i_see_that_67_percent_of_my_audit_is_completed
    and_i_see_that_33_percent_of_my_audit_is_not_completed
  end

  scenario "Displaying the number of items needing improvement/not needing improvement" do
    given_i_am_an_auditor_belonging_to_an_organisation_with_three_content_items
    and_one_content_item_needs_improvement_and_one_does_not
    when_i_visit_the_report_page
    then_i_see_that_50_percent_of_content_needs_improvement
    and_i_see_that_50_percent_of_content_does_not_need_improvement
  end

  scenario "Audit status filter is not present" do
    given_i_am_an_auditor_belonging_to_an_organisation_with_three_content_items
    when_i_visit_the_report_page
    then_i_do_not_see_audit_status_filter
  end

  def then_i_see_the_report_includes_all_three_content_items
    expect(@audit_report_page).to have_report_section(text: '3 Content items')
  end

  def then_i_see_the_report_includes_no_content_items
    expect(@audit_report_page).to have_report_section(text: '0 Content items')
  end

  def then_i_do_not_see_audit_status_filter
    expect(@audit_report_page).to_not have_report_section(text: 'Audit Status')
  end

  def given_i_am_an_auditor_belonging_to_an_organisation_with_three_content_items
    organisation = create(:organisation)
    user = create(:user, organisation: organisation)
    @content_items = create_list(
      :content_item,
      3,
      document_type: "transaction",
      allocated_to: user,
      primary_publishing_organisation: organisation,
    )
  end

  def and_one_content_item_needs_improvement_and_one_does_not
    create(:passing_audit, content_item: @content_items[0])
    create(:failing_audit, content_item: @content_items[1])
  end

  def and_two_items_have_been_audited
    create(:passing_audit, content_item: @content_items[0])
    create(:failing_audit, content_item: @content_items[1])
  end

  def when_i_visit_the_report_page
    @audit_report_page = ContentAuditTool.new.audit_report_page
    @audit_report_page.load(content_id: Content::Item.last.content_id)
  end

  def when_i_select_a_document_type_that_does_not_apply_to_any_content_item
    @audit_report_page.allocated_to.select 'Anyone'
    @audit_report_page.content_type.select 'Guide'
    @audit_report_page.apply_filters.click
  end

  def when_i_select_a_document_type_that_applies_to_all_three_content_items
    @audit_report_page.content_type.select 'Transaction'
    @audit_report_page.apply_filters.click
  end

  def then_i_see_that_67_percent_of_my_audit_is_completed
    expect(@audit_report_page).to have_report_section(text: 'Audited 2 67%')
    expect(@audit_report_page).to have_audit_progress_bar(text: '66.66667% Complete')
  end

  def and_i_see_that_33_percent_of_my_audit_is_not_completed
    expect(@audit_report_page).to have_report_section(text: 'Still to audit 1 33%')
  end

  def then_i_see_that_50_percent_of_content_needs_improvement
    expect(@audit_report_page).to have_report_section(text: 'Need improvement 1 50%')
    expect(@audit_report_page).to have_improvement_progress_bar(text: '50% Complete')
  end

  def and_i_see_that_50_percent_of_content_does_not_need_improvement
    expect(@audit_report_page).to have_report_section(text: "Don't need improvement 1 50%")
  end
end
