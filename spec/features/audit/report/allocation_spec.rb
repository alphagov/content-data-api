RSpec.feature "Content Allocation", type: :feature do
  scenario "Filter allocated content" do
    given_i_am_auditing_a_content_item
    then_i_see_all_content_items
    given_that_i_filter_by_attributes_that_do_not_apply_to_any_content_items
    then_i_see_no_content_items
  end

  def given_i_am_auditing_a_content_item
    organisation = create(:organisation)
    user = create(:user, organisation: organisation)
    content_item = create(
      :content_item,
      title: "Do Androids Dream of Electric Sheep",
      allocated_to: user,
      primary_publishing_organisation: organisation,
    )
    @audit_report = ContentAuditTool.new.audit_report
    @audit_report.load(content_id: content_item.content_id)
  end

  def then_i_see_all_content_items
    expect(@audit_report).to have_report_section(text: '1')
  end

  def given_that_i_filter_by_attributes_that_do_not_apply_to_any_content_items
    @audit_report.allocated_to.select 'No one'
    @audit_report.apply_filters.click
  end

  def then_i_see_no_content_items
    expect(@audit_report).to have_report_section(text: '0')
  end
end
