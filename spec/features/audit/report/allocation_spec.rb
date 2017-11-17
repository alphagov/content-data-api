RSpec.feature "Content Allocation", type: :feature do
  scenario "Filter allocated content" do
    given_i_am_an_auditor_belonging_to_an_organisation
    when_i_visit_the_report_page
    then_i_can_see_the_content_item_i_have_been_allocated
    when_i_select_no_one_in_the_allocated_to_filter
    then_i_cannot_see_the_content_item_i_have_been_allocated
  end

  def given_i_am_an_auditor_belonging_to_an_organisation
    organisation = create(:organisation)
    user = create(:user, organisation: organisation)
    @content_item = create(
      :content_item,
      title: "Do Androids Dream of Electric Sheep",
      allocated_to: user,
      primary_publishing_organisation: organisation,
    )
  end

  def when_i_visit_the_report_page
    @audit_report_page = ContentAuditTool.new.audit_report_page
    @audit_report_page.load(content_id: @content_item.content_id)
  end

  def then_i_can_see_the_content_item_i_have_been_allocated
    expect(@audit_report_page.content_item_count.text).to eq('1')
  end

  def when_i_select_no_one_in_the_allocated_to_filter
    @audit_report_page.allocated_to.select 'No one'
    @audit_report_page.apply_filters.click
  end

  def then_i_cannot_see_the_content_item_i_have_been_allocated
    expect(@audit_report_page.content_item_count.text).to eq('0')
  end
end
