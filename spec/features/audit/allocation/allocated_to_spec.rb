RSpec.feature "Display the users whom content items are allocated to", type: :feature do
  scenario "allocated user's name is displayed in assigned to column for content items with allocated users" do
    given_i_am_a_user_belonging_to_an_organisation
    and_i_have_been_assigned_a_content_item
    when_i_visit_the_assignment_page
    i_see_my_name_in_the_allocated_to_column_for_the_content_item
  end

  scenario "`No one` is displayed in assigned to column for content items without allocated users" do
    given_i_am_a_user_belonging_to_an_organisation
    and_a_content_item_has_not_been_assigned_to_anyone
    when_i_visit_the_assignment_page
    i_see_no_one_in_the_allocated_to_column_for_the_content_item
  end

  def given_i_am_a_user_belonging_to_an_organisation
    @organisation = create(:organisation, title: 'YA Authors')
    @user = create(:user, name: 'Garth Nix', organisation: @organisation)
  end

  def and_i_have_been_assigned_a_content_item
    create(:content_item, allocated_to: @user,
                          title: 'Assigned content item',
                          primary_publishing_organisation: @organisation)
  end

  def when_i_visit_the_assignment_page
    @audit_assignment_page = ContentAuditTool.new.audit_assignment_page
    @audit_assignment_page.load
  end

  def i_see_my_name_in_the_allocated_to_column_for_the_content_item
    @audit_assignment_page.filter_form do |form|
      form.allocated_to.select 'Me'
      form.apply_filters.click
    end
    expect(@audit_assignment_page.assigned_to_columns.first.text). to eq @user.name
  end

  def and_a_content_item_has_not_been_assigned_to_anyone
    create(:content_item, allocated_to: nil,
                          title: 'Unassigned content item',
                          primary_publishing_organisation: @organisation)
  end

  def i_see_no_one_in_the_allocated_to_column_for_the_content_item
    expect(@audit_assignment_page.assigned_to_columns.first.text).to eq 'No one'
  end
end
