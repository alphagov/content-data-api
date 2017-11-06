RSpec.feature "Content Allocation", type: :feature do
  scenario "Filter allocated content" do
    given_i_am_auditing_a_content_item
    then_I_see_all_content_items
    given_that_I_filter_by_attributes_that_do_not_apply_to_any_content_items
    then_I_see_no_content_items
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
    @audit_report_item = ContentAuditTool.new.audit_report_item
    @audit_report_item.load(content_id: content_item.content_id)
  end

  def then_I_see_all_content_items
    expect(@audit_report_item).to have_report_section(text: '1')
  end

  def given_that_I_filter_by_attributes_that_do_not_apply_to_any_content_items
    # TODO think of a better method name
    select "No one", from: "allocated_to"
    click_on "Apply filters"
  end

  def then_I_see_no_content_items
    expect(@audit_report_item).to have_report_section(text: '0')
  end
end
