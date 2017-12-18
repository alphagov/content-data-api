RSpec.feature "`My content` tab", type: :feature do
  scenario 'assigning content items to user to audit' do
    given_i_am_an_auditor_belonging_to_an_organisation
    and_i_have_no_content_items_assigned_to_me
    when_i_visit_the_my_content_page
    then_i_can_see_that_i_have_0_content_items_to_audit
    when_i_navigate_to_assign_content_page
    and_i_assign_2_content_items_to_myself
    then_i_can_see_that_i_have_2_content_items_to_audit
    when_i_filter_on_my_content_items
    when_i_unassign_1_of_my_content_items
    then_i_can_see_that_i_have_1_content_items_to_audit
  end

  scenario 'auditing content items' do
    given_i_am_an_auditor_belonging_to_an_organisation
    and_i_have_5_content_items_assigned_to_me
    when_i_visit_the_my_content_page
    then_i_can_see_that_i_have_5_content_items_to_audit
    when_i_audit_one_of_my_content_items
    then_i_can_see_that_i_have_4_content_items_left_to_audit
  end

  scenario 'on the my content page' do
    given_i_am_an_auditor_belonging_to_an_organisation
    and_i_have_5_content_items_assigned_to_me
    when_i_visit_the_my_content_page
    then_i_can_see_that_i_have_5_content_items_left_to_audit_from_the_my_content_page
  end

  scenario 'on the assign content page' do
    given_i_am_an_auditor_belonging_to_an_organisation
    and_i_have_5_content_items_assigned_to_me
    when_i_visit_the_assign_content_page
    then_i_can_see_that_i_have_5_content_items_left_to_audit_from_the_assignment_page
  end

  scenario 'on the audit progress page' do
    given_i_am_an_auditor_belonging_to_an_organisation
    and_i_have_5_content_items_assigned_to_me
    when_i_visit_the_audit_progress_page
    then_i_can_see_that_i_have_5_content_items_left_to_audit_from_the_progress_page
  end

  def given_i_am_an_auditor_belonging_to_an_organisation
    @organisation = create(:organisation)
    @user = create(:user, organisation: @organisation)
  end

  def and_i_have_no_content_items_assigned_to_me
    create(:content_item,
           title: "Unassigned content item",
           primary_publishing_organisation: @organisation)
    create(:content_item,
           title: "Unassigned content item2",
           primary_publishing_organisation: @organisation)
  end

  def when_i_visit_the_my_content_page
    @audit_content_page = ContentAuditTool.new.audit_content_page
    @audit_content_page.load
  end

  def then_i_can_see_that_i_have_0_content_items_to_audit
    expect(@audit_content_page).to have_my_content_tab(text: 'My content (0)')
  end

  def when_i_navigate_to_assign_content_page
    @audit_assignment_page = ContentAuditTool.new.audit_assignment_page
    @audit_content_page.assign_content_tab.click
    @audit_assignment_page.load
  end

  def when_i_filter_on_my_content_items
    @audit_assignment_page.filter_form do |form|
      form.select 'Me', from: 'Assigned to'
      form.apply_filters.click
    end
  end

  def and_i_assign_2_content_items_to_myself
    @audit_assignment_page.allocation_size.set '2'
    @audit_assignment_page.allocate_to.select 'Me'
    @audit_assignment_page.allocate_button.click
  end

  def then_i_can_see_that_i_have_2_content_items_to_audit
    expect(@audit_assignment_page).to have_my_content_tab(text: 'My content (2)')
  end

  def when_i_unassign_1_of_my_content_items
    @audit_assignment_page.allocation_size.set '1'
    @audit_assignment_page.allocate_to.select 'No one'
    @audit_assignment_page.allocate_button.click
  end

  def then_i_can_see_that_i_have_1_content_items_to_audit
    expect(@audit_assignment_page).to have_my_content_tab(text: 'My content (1)')
  end

  def and_i_have_5_content_items_assigned_to_me
    create_list(:content_item,
                5,
                allocated_to: @user,
                primary_publishing_organisation: @organisation)
  end

  def then_i_can_see_that_i_have_5_content_items_to_audit
    expect(@audit_content_page).to have_my_content_tab(text: 'My content (5)')
  end

  def when_i_audit_one_of_my_content_items
    content_item = Content::Item.last
    @audit_content_item = ContentAuditTool.new.audit_content_item
    @audit_content_item.load(
      content_id: content_item.content_id,
      query: {
        allocated_to: @user.id.to_s,
        audit_status: 'non_audited'
      }
    )
    @audit_content_item.fill_in_audit_form
    @audit_content_item.all_items_link.click
  end

  def then_i_can_see_that_i_have_4_content_items_left_to_audit
    expect(@audit_content_page).to have_my_content_tab(text: 'My content (4)')
  end

  def when_i_visit_the_audit_progress_page
    @audit_report_page = ContentAuditTool.new.audit_report_page
    @audit_report_page.load
  end

  def when_i_visit_the_assign_content_page
    @audit_assignment_page = ContentAuditTool.new.audit_assignment_page
    @audit_assignment_page.load
  end

  def then_i_can_see_that_i_have_5_content_items_left_to_audit_from_the_progress_page
    expect(@audit_report_page).to have_my_content_tab(text: 'My content (5)')
  end

  def then_i_can_see_that_i_have_5_content_items_left_to_audit_from_the_assignment_page
    expect(@audit_assignment_page).to have_my_content_tab(text: 'My content (5)')
  end

  def then_i_can_see_that_i_have_5_content_items_left_to_audit_from_the_my_content_page
    expect(@audit_content_page).to have_my_content_tab(text: 'My content (5)')
  end
end
